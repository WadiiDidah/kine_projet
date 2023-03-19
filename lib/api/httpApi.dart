import 'dart:convert';

import 'package:http/http.dart' as http;


Future<http.Response> getUser(var id) async {
  print("laaa");
  final response = await http.post(
      Uri.parse("http://pedago.univ-avignon.fr:3000/user"),
      headers: {"Accept": "Application/json"},
      body: {"id": id.toString()});
  //print(response.body);
  return response;
}


checkPatient(var login, var password) async {
  final response = await http
      .post(Uri.parse("http://pedago.univ-avignon.fr:3000/patient"), headers: {
    "Accept": "Application/json"
  }, body: {
    "login": login.toString(),
    "pass": password.toString(),
  });
  return response;
}
inscrirePatient(var login , var password , var numTele ) async {
  final response = await http
      .post(Uri.parse("http://pedago.univ-avignon.fr:3000/inscrire"), headers: {
    "Accept": "Application/json"
  }, body: {
    "login": login.toString(),
    "password": password.toString(),
    "numTele": numTele.toString(),
  });

}


