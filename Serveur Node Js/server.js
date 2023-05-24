
const express = require('express')
const morgan = require('morgan')
const cors = require('cors')
const connectDB = require('./config/db')
const passport = require('passport')
const bodyParser = require('body-parser')
const routes = require('./routes/index')
const http = require('http');
const path = require('path');
var User = require('./models/user')
const user = require('./models/user')
const router = require('./routes/index')
var jwt = require('jsonwebtoken')
var config = require('./config/dbconfig')
const https = require('https')
const fs = require('fs');
const WebSocket = require('ws');
const amqp = require('amqplib');



/* On récupère notre clé privée et notre certificat (ici ils se trouvent dans le dossier certificate) */
const key = fs.readFileSync(path.join(__dirname, 'certificate', 'server.key'));
const cert = fs.readFileSync(path.join(__dirname, 'certificate', 'server.cert'));

const options = { key, cert };

console.log("Connexion a la base de donnée en attente");

connectDB()

const app = express()


app.use(express.json());
app.use(express.static("express"));
app.use('/css', express.static(path.join(__dirname, 'node_modules/bootstrap/dist/css')))
app.use('/js', express.static(path.join(__dirname, 'node_modules/bootstrap/dist/js')))
app.use('/js', express.static(path.join(__dirname, 'node_modules/jquery/dist')))

if (process.env.NODE_ENV === 'development') {
    app.use(morgan('dev'))
}

app.use(cors())
app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())
app.use(routes)
app.use(passport.initialize())
require('./config/passport')(passport)


  
// Create the HTTPS server
const server = https.createServer(options, app);


  // Start the server
server.listen(3000, () => {
    console.log('App is running! Go to https://localhost:3000');
});


// RabbitMQ connection URL
const rabbitmqUrl = 'amqp://localhost';

// WebSocket connections for online users
const onlineUsers = new Map();

async function startConsumer() {
    try {
      // Connect to RabbitMQ
      const connection = await amqp.connect(rabbitmqUrl);
      const channel = await connection.createChannel();
  
      // Declare the durable queue
      const queueName = 'messageQueue';
      await channel.assertQueue(queueName, { durable: true });
  
      // Start consuming messages from the queue
      channel.consume(queueName, (message) => {
        if (message !== null) {
          const content = message.content.toString();
          const recipient = message.properties.headers.recipient;
  
          // Check if recipient is online
          if (onlineUsers.has(recipient)) {
            // Deliver the message to recipient's WebSocket connection
            const ws = onlineUsers.get(recipient);
            ws.send(content);
          } else {
            console.log(`Recipient ${recipient} is offline. Message stored in the queue.`);
          }
  
          // Acknowledge the message from the queue
          channel.ack(message);
        }
      });
    } catch (error) {
      console.error('Error occurred:', error);
    }
}

function establishWebSocketConnection(user) {
    // Create a WebSocket connection
    const ws = new WebSocket('ws://your-server-url');
  
    // Add event listeners to handle WebSocket events
    ws.onopen = () => {
      console.log('WebSocket connection established');
      // Perform any necessary operations when the connection is opened
    };
  
    ws.onmessage = (event) => {
      console.log('Received message:', event.data);
      // Handle incoming messages from the server
    };
  
    ws.onclose = () => {
      console.log('WebSocket connection closed');
      // Perform any necessary cleanup or reconnection logic
    };
  
    // Return the WebSocket connection object
    return ws;
  }


// Example code to handle WebSocket connections and track online users
async function handleWebSocketConnection(ws) {
    // Get the recipient's identifier from the WebSocket connection
    const recipient = 'user123'; // Replace with appropriate logic to get recipient
  
    // Store the WebSocket connection for the recipient
    onlineUsers.set(recipient, ws);
  
    // Handle WebSocket close event
    ws.on('close', () => {
      // Remove the WebSocket connection when the user goes offline
      onlineUsers.delete(recipient);
    });
  
    // Check if there are pending messages for the recipient in the durable queue
    const connection = await amqp.connect(rabbitmqUrl);
    const channel = await connection.createChannel();
    const queueName = 'messageQueue';
  
    // Consume messages from the durable queue for the recipient
    channel.consume(
      queueName,
      (message) => {
        if (message !== null) {
          const content = message.content.toString();
          const messageRecipient = message.properties.headers.recipient;
  
          if (messageRecipient === recipient) {
            // Deliver the message to the recipient's WebSocket connection
            ws.send(content);
          }
  
          // Acknowledge the message from the queue
          channel.ack(message);
        }
      },
      { noAck: false } // Set noAck to false to manually acknowledge the messages
    );
}

// Function to send a message to a specific user
function sendMessageToUser(userId, message, ws) {
    const userConnection = userConnections.get(userId);
    if (userConnection) {
      const { ws, channel } = userConnection;
      ws.send(JSON.stringify({ channel, message }));
    }
  }


// Création du serveur WebSocket
const wss = new WebSocket.Server({ server });

// Maintain a mapping of user ID to WebSocket connections
const userConnections = new Map();


function extractUserIdFromRequest(req) {
    // Assuming the user ID is stored in the JWT's payload under the 'userId' claim
    const token = req.headers.authorization.split(' ')[1]; // Assuming the JWT is passed in the 'Authorization' header
    const decodedToken = jwt.verify(token, config.secret);
    const userId = decodedToken.id;
    return userId;
  }

// Gestion des connexions WebSocket
wss.on('connection', (ws, req) => {
    console.log(" connection web socket")
    // Gérer les événements WebSocket ici

    const userId = extractUserIdFromRequest(req);
    //const userId = '99';
    console.log("c'est l'id extract avant ws : " + userId)

    // Assign a channel/topic to the client based on the user ID
    const channel = `channel_${userId}`;

    // Store the WebSocket connection in the mapping
    userConnections.set(userId, { ws, channel });

    console.log(userConnections);


  ws.on('message', (message) => {
    const demande = JSON.parse(message);

    console.log(demande);
    if (demande.type === 'messagesend') {
        // Traiter la nouvelle demande de rendez-vous
        // Enregistrer la demande en base de données, notifier le kiné, etc.
        // Handle the received message
        const token = demande.token;
        const content = demande.content;

        // Process the message, such as saving it to the database, sending notifications, etc
      
        sendMessageToUser(userId,content,ws);
      
    }

    // ... Autres types de demandes (mise à jour, annulation, etc.) ...
  });

});


function checkWebSocketConnections() {
    userConnections.forEach((connection, userId) => {
      const { ws, channel } = connection;
      
      if (ws.readyState === WebSocket.CLOSED) {
        // Connection is closed, remove the user from the map
        userConnections.delete(userId);
        
        // Perform any necessary cleanup or reconnection logic for the user
        
      }
    });
}
// Run the checkWebSocketConnections function every second
setInterval(checkWebSocketConnections, 1000);
  