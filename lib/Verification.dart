import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

double screenHeight = 0;
double screenWidth = 0;
double bottom = 0;

String countryDial = "+1";
String verID = " ";

int screenState = 0;

Color blue = const Color(0xff8cccff);


String _verificationCode = '';
//String code_saisi="";


Future<String> verifyCode(String code_saisi) async {
  try {
    print("verification_code: ************* "+_verificationCode);

    final PhoneAuthCredential credential = PhoneAuthProvider.credential(

      verificationId: _verificationCode,
      smsCode:code_saisi,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    print('Phone number verified successfully');
    return 'true';
  } catch (e) {
    print('Failed to verify phone number: $e');
    return "l'authenification n'est pas faite";
  }
}






Future<void> sendVerificationCode(String phone_number) async {

  final PhoneVerificationCompleted verificationCompleted =
      (PhoneAuthCredential phoneAuthCredential) async {
    await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
  };

  final PhoneVerificationFailed verificationFailed =
      (FirebaseAuthException authException) {
    print('Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
  };

  final PhoneCodeSent codeSent =
      (String verificationId, int? resendToken) async {
    _verificationCode = verificationId;
  };

  final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
      (String verificationId) {
    _verificationCode = verificationId;
  };

  try {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber:phone_number,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 30),
    );
  } catch (e) {
    print('Failed to verify phone number: $e');
  }
}