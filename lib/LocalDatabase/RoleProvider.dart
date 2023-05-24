import 'package:flutter/foundation.dart';

class RoleProvider with ChangeNotifier {
  String _role = '';

  String get role => _role;

  setRole(String newRole) {
    _role = newRole;
    notifyListeners();
  }

  clearRole() {
    _role = '';
    notifyListeners();
  }
}
