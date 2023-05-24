import 'package:flutter/cupertino.dart';
import 'package:kine/api/WebSocketProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../LocalDatabase/DatabaseProvider.dart';

class MyApplicationObserver extends WidgetsBindingObserver {

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);


    /**
    if (state == AppLifecycleState.detached) {
      // Appelé lorsque l'application est en pause (fermée complètement)
      // Supprimer le SharedPreferences
      DatabaseProvider().removeAll();
      DatabaseProvider().removeToken();
      print("on sort de l'app");
      // Fermer la connexion WebSocket
      // ...
    }

    if (state == AppLifecycleState.paused) {
      // Appelé lorsque l'application est en pause (fermée complètement)
      // Supprimer le SharedPreferences
      DatabaseProvider().removeAll();
      DatabaseProvider().removeToken();
      print("on sort de l'app");
      // Fermer la connexion WebSocket
      // ...
    }
        **/


  }
}