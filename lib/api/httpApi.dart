import 'dart:convert';
import 'dart:io';

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


inscrire(var name , var password ) async {

  print( "alors ? " + name.toString()+" "+ password);
  // Create a custom HttpClient with a custom security context
  final httpClient = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) {
      return true; // Allow self-signed and invalid certificates
    };

  // Prepare the request body
  final requestBody = {
    "name": name.toString(),
    "password": password.toString(),
  };

  // Make the request
  final request = await httpClient.postUrl(
    Uri.parse("https://10.0.2.2:3000/adduser"),
  );
  request.headers.set("Accept", "application/json"); // Set the headers
  request.write(json.encode(requestBody));
  final response = await request.close();

  // Read the response
  final responseBody = await response.transform(utf8.decoder).join();

  // Close the HttpClient
  httpClient.close();

  return http.Response(responseBody, response.statusCode);

}


