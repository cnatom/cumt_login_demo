import 'package:flutter/material.dart';

import 'login.dart';

class LoginPageProvider with ChangeNotifier {

  LoginPageProvider(){
    _loginLocation = CumtLoginLocation.nh;
    _loginMethod = CumtLoginMethod.cumt;
  }
  late CumtLoginLocation _loginLocation;
  late CumtLoginMethod _loginMethod;

  CumtLoginLocation get loginLocation => _loginLocation;

  CumtLoginMethod get loginMethod => _loginMethod;

  setMethodLocation(CumtLoginMethod method, CumtLoginLocation location) {
    _loginMethod = method;
    _loginLocation = location;
    notifyListeners();
  }
}
