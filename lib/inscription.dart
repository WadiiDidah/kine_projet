import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import'api/httpApi.dart';
import 'Verification.dart';
import 'verfiWidget.dart';
import 'sendCode.dart';


class Inscription extends StatefulWidget {



  Inscription();

  @override
  State<Inscription> createState() {
    return _Inscription();
  }
}

class _Inscription extends State<Inscription> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  String login = "";
  String password = "";
  var message_eror = "";
  final _keyForm = GlobalKey<FormState>();

  var shared;


  bool passToogle = false;
  TextEditingController loginController = new TextEditingController();
  TextEditingController passController = new TextEditingController();

  TextEditingController countryController = new TextEditingController(text:"+33");
  TextEditingController phonenumber = new TextEditingController();


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    String message="";
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
                SizedBox(height: 30.0),
                Text(
                  "Créer un compte de Patient",
                  style: TextStyle(
                    fontFamily: 'Varela',
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 15.0),
                Center(child: Image(image: AssetImage("assets/officiel.png"))),
                SizedBox(height: 10.0),
                Center(
                    child: Text(
                      "Vous êtes un nouveau Patient",
                      style: TextStyle(
                        fontFamily: 'Varela',
                        fontSize: 19.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    )),
                SizedBox(height: 15.0),
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
                SizedBox(height: 20.0),
              IntlPhoneField(
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone',
                  border: OutlineInputBorder(),
                ),
                initialCountryCode: 'FR',
                onChanged: (value) => message = value.completeNumber,
                // completeNumber
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
                    await Firebase.initializeApp();
                   await sendVerificationCode(message);
                    print(message + " " + loginController.text+" "+ passController.text);
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => SendCode(login:loginController.text ,password:passController.text,num:message)));

                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(5)),
                    child: Center(
                      child: Text(
                        "S'inscrire",
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

              ],
            ),
          ),
        ),
      ),
    );
  }
}
