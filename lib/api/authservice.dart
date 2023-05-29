


import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io' as IO;

class AuthService {
  Dio dio = Dio();


  AuthService() {
    // Create a custom HttpClient with certificate verification disabled
    final httpClient = IO.HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;

    // Pass the custom HttpClient to the Dio instance
    dio.httpClientAdapter = DefaultHttpClientAdapter()
      ..onHttpClientCreate = (client) => httpClient;

    // Configure other options for the Dio instance, such as base URL or headers
    dio.options.baseUrl = "https://10.0.2.2:3000";
    dio.options.headers = {
      "Content-Type": "application/json",
      // Add any other headers you need for authentication
    };
  }

  loginClient(name, password) async{
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    try {
      if(IO.Platform.isAndroid) {
        return await dio.post('https://10.0.2.2:3000/authenticate', data : {
          "name": name,
          "password": password
          }, options: Options(contentType: Headers.formUrlEncodedContentType )
        );
      } else {
        return await dio.post('https://172.20.10.4:3000/authenticate', data : {
          "name": name,
          "password": password
        },
        );
      }
    }
    on DioError catch(e) {
      Fluttertoast.showToast(msg: e.response?.data['msg'],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
      );
    }
  }


  loginKine(name, password) async{
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    try {

      if(IO.Platform.isAndroid) {
        return await dio.post('https://10.0.2.2:3000/authenticateKine', data : {
          "name": name,
          "password": password
        }, options: Options(contentType: Headers.formUrlEncodedContentType )
        );
      } else {
        return await dio.post('https://172.20.10.4:3000/authenticateKine', data : {
          "name": name,
          "password": password
        },
        );
      }
    }
    on DioError catch(e) {
      Fluttertoast.showToast(msg: e.response?.data['msg'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }



  lookForName(id) async {
    try {
      if (IO.Platform.isAndroid) {
        return await dio.post('http://10.0.2.2:8080/name', data: {
          "id": id,

        }, options: Options(contentType: Headers.formUrlEncodedContentType)
        );
      } else {
        return await dio.post('http://172.20.10.4:8080/name', data: {
          'id':id,

        }, options: Options(contentType: Headers.formUrlEncodedContentType)
        );
      }
    }
    on DioError catch(e) {
      Fluttertoast.showToast(msg: e.response?.data['msg'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  adduser(name, password, num) async{

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    print("aller on add");
    try {
      if (IO.Platform.isAndroid) {
        print("android la");
        final response =  await dio.post('https://10.0.2.2:3000/adduser', data: {
          "name": name,
          "password": password,
          'numtel': num
        }, options: Options(contentType: Headers.formUrlEncodedContentType)

        );
        return response;
      } else {
        final response = await dio.post('https://172.20.10.4:3000/adduser', data: {
          "name": name,
          "password": password,
          'numtel': num
        }, options: Options(contentType: Headers.formUrlEncodedContentType)
        );
        return response;
      }

    }

    on DioError catch(e) {
      Fluttertoast.showToast(msg: e.response?.data['msg'],
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0
      );
    }

  }


  getAllPatient(name) async{

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    print("on cherche par nom" + name);
    try {
      if (IO.Platform.isAndroid) {
        print("android la");
        return await dio.post('https://10.0.2.2:3000/getUserByName', data: {
          "name": name,
        }, options: Options(contentType: Headers.formUrlEncodedContentType)

        );

      } else {
        return await dio.post('https://172.20.10.4:3000/getUserByName', data: {
          "name": name,
        }, options: Options(contentType: Headers.formUrlEncodedContentType)
        );

      }

    }

    on DioError catch(e) {
      Fluttertoast.showToast(msg: e.response?.data['msg'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }

  }

  // Cette fonction permet simplement de retourner
  // les informations d'un user en fonction de son token
  getInfoUser(token) async{

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    print("aller on get info la");
    try {
      if (IO.Platform.isAndroid) {


        print("android la dans get info");
        dio.options.headers['Authorization'] = 'Bearer $token';
        return await dio.get('https://10.0.2.2:3000/getinfo');

      } else {
        print("android la dans get info");
        dio.options.headers['Authorization'] = 'Bearer $token';
        return await dio.get('https://172.20.10.4:3000/getinfo');
      }

    }

    on DioError catch(e) {
      Fluttertoast.showToast(msg: e.response?.data['msg'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }

  }

}
