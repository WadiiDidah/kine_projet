


import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io' as IO;

import 'package:kine/ClassAll/TimeSlot.dart';

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


  addRdv(DateTime dateTime, String start, String end) async{

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    print("aller on add" + start + end);
    try {
      if (IO.Platform.isAndroid) {
        try{

          final response =  await dio.post('https://10.0.2.2:3000/addRdv', data: {
            "year": dateTime.year.toString(),
            "month": dateTime.month.toString(),
            "day": dateTime.day.toString(),
            "starthour": start.toString(),
            "endhour": end.toString(),
          }, options: Options(contentType: Headers.formUrlEncodedContentType)

          );
          return response;
        }catch(e){
          print(e);
        }

      } else {
        final response = await dio.post('https://172.20.10.4:3000/addRdv', data: {
          "year": dateTime.year,
          "month": dateTime.month,
          'day': dateTime.day,
          'starthour': start,
          'endhour': end,
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


  getAllUSerInBdd() async{

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };


    try {
      if (IO.Platform.isAndroid) {
        print("android la");
        return await dio.post('https://10.0.2.2:3000/getallusers', data: {

        }, options: Options(contentType: Headers.formUrlEncodedContentType)

        );

      } else {
        return await dio.post('https://172.20.10.4:3000/getallusers', data: {

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


  getInfoUserByID(id) async{

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    print("on cherche par id :" + id);

    try {
      if (IO.Platform.isAndroid) {
        print("android la");
        final response =  await dio.post('https://10.0.2.2:3000/getUserById', data: {
          "id": id.toString(),
        }, options: Options(contentType: Headers.formUrlEncodedContentType)

        );

        return response;

      } else {
        final response =  await dio.post('https://172.20.10.4:3000/getUserById', data: {
          "id": id,
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

  getInfoKineByID(id) async{

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    print("on cherche par id :" + id);

    try {
      if (IO.Platform.isAndroid) {
        print("android la");
        final response =  await dio.post('https://10.0.2.2:3000/getKineById', data: {
          "id": id.toString(),
        }, options: Options(contentType: Headers.formUrlEncodedContentType)

        );

        return response;

      } else {
        final response =  await dio.post('https://172.20.10.4:3000/getKineById', data: {
          "id": id,
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

  // Cette fonction permet simplement de retourner
  // les informations d'un user en fonction de son token
  Future<bool> isTimeSlotTaken(TimeSlot timeSlot, year, month, day) async{

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    final String starthour = '${timeSlot.startHour.hour}:${timeSlot.startHour.minute.toString().padLeft(2, '0')}';
    final String endhour = '${timeSlot.endHour.hour}:${timeSlot.endHour.minute.toString().padLeft(2, '0')}';


    try {
      if (IO.Platform.isAndroid) {
        print(year);
        print(month);
        print(day);
        print(timeSlot);

        final response =  await dio.post('https://10.0.2.2:3000/getrdvbyall', data: {
          "year": year.toString(),
          "month": month.toString(),
          "day": day.toString(),
          "starthour": starthour,
          "endhour": endhour,
        }, options: Options(contentType: Headers.formUrlEncodedContentType)

        );
        if (response != null) {
          final responseData = json.decode(response.toString());
          //print(responseData);
          if (responseData['success']) {
            print("success");
            return true;
          } else {
            return false;
          }
        }
        return false;
      }
      return false;
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
    return false;

  }

  // Cette fonction permet simplement de retourner
  // les informations d'un user en fonction de son token
  Future<void> isFcmtokenSame(String fcmtoken, String iduser, role) async{

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    try {
      if (IO.Platform.isAndroid) {
        print("fcmtoken dans authservice" + fcmtoken);
        print("iduser dans auth" +iduser);

        final response =  await dio.post('https://10.0.2.2:3000/verifyfcmtoken', data: {
          "fcmtoken": fcmtoken.toString(),
          "iduser": iduser.toString(),
          "role": role.toString()

        }, options: Options(contentType: Headers.formUrlEncodedContentType)

        );

          final responseData = json.decode(response.toString());
          //print(responseData);
          if (responseData['success']) {
            print("message du success fcmtoken" + responseData['msg']);

          } else  {
            print("Grosse erreur" +  responseData['msg']);

          }
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


  Future<dynamic> getFcmtokenById(String iduser, String ?role) async{

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    try {
      if (IO.Platform.isAndroid) {
        print("iduser dans auth" +iduser);
        print("le role dans auth" +role!);

        if (role == "kine"){
          final response =  await dio.post('https://10.0.2.2:3000/getfcmtokenbyid', data: {
            "iduser": iduser.toString(),

          }, options: Options(contentType: Headers.formUrlEncodedContentType)

          );

          final responseData = json.decode(response.toString());
          //print(responseData);
          if (responseData['success']) {
            return responseData['fcmtoken'];
          } else {
            print("La y'a un problème on sait pas pq");
          }

        } else {
          print("getfcmtokenbyidkine");
          final response =  await dio.post('https://10.0.2.2:3000/getfcmtokenbyidkine', data: {
            "iduser": iduser.toString(),

          }, options: Options(contentType: Headers.formUrlEncodedContentType)

          );

          final responseData = json.decode(response.toString());
          //print(responseData);
          if (responseData['success']) {
            return responseData['fcmtoken'];
          } else {
            print("La y'a un problème on sait pas pq");
          }
        }

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