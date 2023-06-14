import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'api/httpApi.dart';
import 'Verification.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:pinput/pinput.dart';
import 'Verification.dart';
import 'homeKine.dart';
import 'homePatient.dart';

class SendCode extends StatefulWidget {
  var login;
  var password;
  var num;

  SendCode({this.login, this.password, this.num});

  @override
  State<SendCode> createState() {
    return _SendCode(login: this.login, password: this.password, num: this.num);
  }
}

class _SendCode extends State<SendCode> {
  var login;
  var password;
  var num;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("les identifnats reçus sont : " +
        this.login +
        " " +
        this.password +
        " " +
        this.num);
  }

  _SendCode({this.login, this.password, this.num});

  TextEditingController countryController =
  new TextEditingController(text: '+');
  var pin_saisi = "";
  var message_eror = "";

  void showError() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...',
      confirmBtnText: "Ok",
      text:
      'Le code que vous avez saisi est incorrect. Veuillez vérifier et réessayer',
    );
  }

  void showSucces() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      confirmBtnText: "Ok",
      text:
      'Félicitations ! Connexion réussie !!',
    );
  }

  void showAlerte() {
    String message = "";
    QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        barrierDismissible: true,
        title: "Changement du numéro de téléphone",
        confirmBtnText: 'Enregistrer',
        onConfirmBtnTap: () async {
          if (!message.isEmpty) {
            //await Firebase.initializeApp();
            //sendVerificationCode(message); //envoyer le code de vérification

            setState(() {
              this.num = message;
            });

            print("le nouveau numéro de téléphone est " + this.num);
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SendCode(
                    login: this.login, password: this.password, num: message)));
          } else {}
          ;
        },
        widget: IntlPhoneField(
          decoration: InputDecoration(
            labelText: 'Numéro de téléphone',
            border: OutlineInputBorder(),
          ),
          initialCountryCode: 'FR',
          onChanged: (value) => message = value.completeNumber,
          // completeNumber
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        margin: EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/officiel.png',
                width: 150,
                height: 150,
              ),
              SizedBox(
                height: 25,
              ),
              Text(
                "Phone Verification",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "We need to register your phone without getting started!",
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 30,
              ),
              Pinput(
                length: 6,
                // defaultPinTheme: defaultPinTheme,
                // focusedPinTheme: focusedPinTheme,
                // submittedPinTheme: submittedPinTheme,

                showCursor: true,
                onCompleted: (pin) => pin_saisi = pin,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                message_eror,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () async {
                      String result = await verifyCode(pin_saisi);
                      //String result ="true";
                      print("le resultat est ******: "+result);
                      if (result == "true") {
                        showSucces();
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePatient()));

                      } else
                        showError();
                    },
                    child: Text("Verify Phone Number")),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
