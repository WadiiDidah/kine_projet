import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kine/api/authservice.dart';
import 'package:kine/homePatient.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LocalDatabase/DatabaseProvider.dart';
import 'api/WebSocketProvider.dart';
import'api/httpApi.dart';
import 'inscription.dart';


class FormPatient extends StatefulWidget {

  var page;
  var id_post;

  FormPatient({this.page});

  @override
  State<FormPatient> createState() {
    return _FormPatient(page:page);
  }
}

class _FormPatient extends State<FormPatient> {
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

  _FormPatient({this.page});



  void showError() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...',
      confirmBtnText: "Ok",
      text:
      "l'identifiant ou le mot de passe  est incorrect. Veuillez vérifier et  réessayer",
    );
  }

  @override
  Widget build(BuildContext context) {
    final webSocketProvider = Provider.of<WebSocketProvider>(context);
    final messages = webSocketProvider.messages;
    // TODO: implement build
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 60.0),
          child: Form(
            key: _keyForm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50.0),
                const Text(
                  "Espace Patient",
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
                      "Vous êtes Patient",
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
                const SizedBox(height: 20.0),
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

                const SizedBox(height: 3.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Mot de passe oublié?",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 1.0),

                InkWell(
                  onTap: () async {
                    var login = loginController.text.toString();
                    var password = passController.text.toString();

                    //var response = await checkPatient(login, password);
                    var response = await AuthService().loginClient(login, password);
                    setState(() {});

                    if (response != null) {
                      final responseData = json.decode(response.toString());

                      if (responseData['success'] == true) {
                        // Login successful
                        final message = responseData['msg'];
                        final token = responseData['token'];

                        // Storing the token
                        void storeToken(String token) async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setString('token', token);
                        }

                        storeToken(token);


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
                            MaterialPageRoute(builder: (context) => HomePatient(role: 'user',)
                          )
                        );
                        //Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePatient() ));

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
                    child: const Center(
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
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: () {

                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => Inscription() ));
                        },
                        child: const Text(
                          "Vous n'avez pas de compte?",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
