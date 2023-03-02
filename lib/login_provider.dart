import 'package:cumt_login_demo/prefs.dart';
import 'package:flutter/material.dart';

import 'login.dart';

class LoginPageProvider with ChangeNotifier {

  LoginPageProvider(){
    _loginLocation = CumtLoginLocation.nh;
    _loginMethod = CumtLoginMethod.cumt;
    if(Prefs.cumtLoginLocation != "" && Prefs.cumtLoginMethod != ""){
      _loginLocation = CumtLoginLocationExtension.fromName(Prefs.cumtLoginLocation);
      _loginMethod = CumtLoginMethodExtension.fromName(Prefs.cumtLoginMethod);
    }
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
