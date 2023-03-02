import 'dart:convert';
import 'package:cumt_login_demo/prefs.dart';
import 'package:dio/dio.dart';

enum CumtLoginLocation {
  nh, // 南湖
  wc // 文昌
}

extension CumtLoginLocationExtension on CumtLoginLocation {
  String loginUrl(
      String username, String password, CumtLoginMethod loginMethod) {
    String head =
        "http://10.2.5.251:801/eportal/?c=Portal&a=login&login_method=1&user_account=$username${loginMethod.code}&user_password=$password";
    switch (this) {
      case CumtLoginLocation.nh:
        return head;
      case CumtLoginLocation.wc:
        return "$head&wlan_ac_name=BRAS";
    }
  }

  String get logoutUrl {
    String head =
        "http://10.2.5.251:801/eportal/?c=Portal&a=logout&login_method=1";
    switch (this) {
      case CumtLoginLocation.nh:
        return head;
      case CumtLoginLocation.wc:
        return "$head&wlan_ac_name=BRAS";
    }
  }

  String get name {
    switch (this) {
      case CumtLoginLocation.nh:
        return '南湖';
      case CumtLoginLocation.wc:
        return '文昌';
    }
  }

  static List<String> get nameList {
    return CumtLoginLocation.values.map((e) => e.name).toList(growable: false);
  }

  //根据name获取枚举
  static CumtLoginLocation fromName(String name) {
    return CumtLoginLocation.values
        .firstWhere((element) => element.name == name);
  }
}

enum CumtLoginMethod {
  cumt, // 校园网
  telecom, // 电信
  unicom, // 联通
  cmcc // 移动
}

void func() {
  CumtLoginMethod method = CumtLoginMethod.cmcc;
  method.name;
}

extension CumtLoginMethodExtension on CumtLoginMethod {
  String get code {
    switch (this) {
      case CumtLoginMethod.cumt:
        return '';
      case CumtLoginMethod.telecom:
        return '%40telecom';
      case CumtLoginMethod.unicom:
        return '%40unicom';
      case CumtLoginMethod.cmcc:
        return '%40cmcc';
    }
  }

  String get name {
    switch (this) {
      case CumtLoginMethod.cumt:
        return '校园网';
      case CumtLoginMethod.telecom:
        return '电信';
      case CumtLoginMethod.unicom:
        return '联通';
      case CumtLoginMethod.cmcc:
        return '移动';
    }
  }

  static List<String> get nameList {
    return CumtLoginMethod.values.map((e) => e.name).toList(growable: false);
  }

  //根据name获取枚举
  static CumtLoginMethod fromName(String name) {
    return CumtLoginMethod.values.firstWhere((element) => element.name == name);
  }
}

class CumtLogin {

  static Future<String> logout(
      {required CumtLoginLocation loginLocation}) async {
    try {
      Response res;
      Dio dio = Dio();
      String url = loginLocation.logoutUrl;
      //配置dio信息
      res = await dio.get(url);
      //Json解码为Map
      Map<String, dynamic> map =
          jsonDecode(res.toString().substring(1, res.toString().length - 1));
      return map["msg"].toString();
    } catch (e) {
      return '网络错误(X_X)';
    }
  }

  static _savePrefs(
      {required String username,
      required String password,
      required CumtLoginMethod loginMethod,
      required CumtLoginLocation loginLocation}) {
    Prefs.cumtLoginUsername = username;
    Prefs.cumtLoginPassword = password;
    Prefs.cumtLoginMethod = loginMethod.name;
    Prefs.cumtLoginLocation = loginLocation.name;
  }

  static Future<String> login(
      {required String username,
      required String password,
      required CumtLoginMethod loginMethod,
      required CumtLoginLocation loginLocation}) async {
    try {
      Response res;
      Dio dio = Dio();
      String url = loginLocation.loginUrl(username, password, loginMethod);
      res = await dio.get(url);
      Map<String, dynamic> map =
          jsonDecode(res.toString().substring(1, res.toString().length - 1));
      _savePrefs(
          username: username,
          password: password,
          loginMethod: loginMethod,
          loginLocation: loginLocation);
      if (map['result'] == "1") {
        return '登录成功';
      } else {
        switch (map["ret_code"]) {
          case "2":
            {
              return '您已登录校园网';
            }
          case "1":
            {
              if (map['msg'] == "dXNlcmlkIGVycm9yMg==") {
                return '账号或密码错误';
              } else if (map['msg'] == 'dXNlcmlkIGVycm9yMQ==') {
                return '账号不存在，请切换运营商再尝试';
              } else if (map['msg'] == 'UmFkOkxpbWl0IFVzZXJzIEVycg==') {
                return '您的登陆超限\n请在"用户自助服务系统"下线终端。';
              } else {
                return '未知错误，但是不影响使用';
              }
            }
        }
        return "";
      }
    } catch (e) {
      return "登录失败，确保您已经连接校园网(CUMT_Stu或CUMT_tec)";
    }
  }
}
