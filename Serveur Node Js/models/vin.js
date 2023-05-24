var mongoose = require('mongoose')
var Schema = mongoose.Schema;
var bcrypt = require('bcryptjs');



var vinSchema = new Schema({
    name: {
        type: String,
        require: true
    },
    descriptif: {
        type: String,
        require: false
    },
    embouteillage: {
        type: Number,
        require: false
    },
    nomcepage: {
        type: String,
        require: false
    },
    nomchateau: {
        type: String,
        require: false
    },
    prix: {
        type: Number,
        require: false
    },
    likes: {
        type:Number,
        require:false
    },
    comments: [
        { 
            body: String, 
            commentBy: String
        },
    ], require:false,
}
)

module.exports = mongoose.model('Vin', vinSchema)