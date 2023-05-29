import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kine/LocalDatabase/DatabaseProvider.dart';
import 'package:kine/api/WebSocketProvider.dart';
import 'package:kine/homeKine.dart';
import 'api/authservice.dart';
import 'package:shared_preferences/shared_preferences.dart';


class FormKine extends StatefulWidget {
  var page;
  var id_post;

  FormKine({this.page});

  @override
  State<FormKine> createState() {
    return _FormKine(page: page);
  }
}

class _FormKine extends State<FormKine> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    DatabaseProvider().removeToken();
    print("oke");
    print(page);
  }

  var page;
  String login = "";
  String password = "";
  var message_eror = "";
  final _keyForm = GlobalKey<FormState>();

  var shared;

  bool passToogle = false;
  TextEditingController loginController = new TextEditingController();
  TextEditingController passController = new TextEditingController();

  _FormKine({this.page});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 60.0),
          child: Form(
            key: _keyForm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50.0),
                const Text(
                  "Espace Kiné",
                  style: TextStyle(
                    fontFamily: 'Varela',
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30.0),
                const Center(child: Image(image: AssetImage("assets/officiel.png"))),
                const SizedBox(height: 10.0),
                const Center(
                    child: Text(
                  "Vous êtes kiné",
                  style: TextStyle(
                    fontFamily: 'Varela',
                    fontSize: 19.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                )),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: loginController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: "Login",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: passController,
                  obscureText: passToogle,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    suffix: InkWell(
                      onTap: () {
                        setState(() {
                          passToogle = !passToogle;
                        });
                      },
                      child: Icon(
                          passToogle ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                  validator: (value) {
                    //print("la valeur est $value");
                  },
                ),
                SizedBox(height: 10.0),
                Text(
                  message_eror,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    var login = loginController.text.toString();
                    var password = passController.text.toString();

                    //var response = await checkPatient(login, password);
                    var response = await AuthService().loginKine(login, password);
                    setState(() {});
                    if (response != null) {
                      final responseData = json.decode(response.toString());

                      if (responseData['success'] == true) {
                        // Login successful
                        final message = responseData['msg'];
                        final token = responseData['token'];

                        // on stocke le token en shared preference
                        DatabaseProvider().storeToken(token);

                        print('Login successful: $message');
                        print('token : $token');

                        AuthService().getInfoUser(token).then((val){
                          Fluttertoast.showToast(
                            msg: val.data['msg'],
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                        });
                        ///final responseD = json.decode(rep.toString());

                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => HomeKine(role: 'kine',)
                            )
                        );

                        //Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeKine() ));

                      } else {
                        // Login failed
                        final message = responseData['msg'];
                        print('Login failed: $message');
                      }
                    } else {
                      // Request failed or encountered an error
                      print('Login request failed');
                    }
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(5)),
                    child: Center(
                      child: Text(
                        "Se connecter",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Mot de passe oublie?",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                        onPressed: () {},
                        child: Text(
                          "Clicker ici",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
