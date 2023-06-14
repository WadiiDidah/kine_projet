import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kine/Verification.dart';
import 'package:kine/homeKine.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'api/httpApi.dart';
import 'validateConnexion.dart';


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
                Text(
                  "Espace Kiné",
                  style: TextStyle(
                    fontFamily: 'Varela',
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 30.0),
                Center(child: Image(image: AssetImage("assets/officiel.png"))),
                SizedBox(height: 10.0),
                Center(
                    child: Text(
                      "Vous êtes kiné",
                      style: TextStyle(
                        fontFamily: 'Varela',
                        fontSize: 19.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    )),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: loginController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
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

                    var response = await checkPatient(login, password);
                    setState(() {});
                    if (response.body != "false") {
                      /*var responseJson = json.decode(response.body);
                      print("la reponse est " +
                          responseJson["tel"].toString());
                      await Firebase.initializeApp();
                      await sendVerificationCode(
                          responseJson["tel"].toString());
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SendCode(
                              login: loginController.text,
                              password: passController.text,
                              num: responseJson["tel"].toString())));*/

                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>HomeKine()));
                      message_eror = "";
                    } else {
                      showError();
                      print("la reponse est " + response.body);
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
