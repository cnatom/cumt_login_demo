import 'package:cumt_login_demo/login.dart';
import 'package:cumt_login_demo/prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:provider/provider.dart';

import 'login_provider.dart';

main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => LoginPageProvider(),
      child: MaterialApp(
        home: LoginPage(),
      ),
    );
  }
}



class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver{
  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _usernameController.text = Prefs.cumtLoginUsername;
    _passwordController.text = Prefs.cumtLoginPassword;
    if (Prefs.cumtLoginUsername != "" && Prefs.cumtLoginPassword != "") {
      _handleLogin(context);
    }
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 在resumed的时候自动登录校园网
    if (state == AppLifecycleState.resumed) {
      _handleLogin(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    if(DateTime.now().isAfter(DateTime(2023,3,5))){
      return const Scaffold(
        body: Center(
          child: Text("该测试版已过期\n请加QQ群：839372371或957634136获取最新版本",textAlign: TextAlign.center,),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('矿小助CUMT校园网登录 1.0'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16.0),
              buildTextField("账号", _usernameController),
              const SizedBox(height: 16.0),
              buildTextField("密码", _passwordController, obscureText: true),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildPicker(),

                  ElevatedButton(
                    onPressed: () => _handleLogin(context),
                    child: const Text('登录'),
                  ),
                  OutlinedButton(
                    onPressed: () => _handleLogout(context),
                    child: const Text('注销'),
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              Text("本App用于测试矿小助新功能\n"
                  "3月15日之后将停用并移植到新版矿小助中\n"
                  "如果遇到问题请加QQ群反馈\n"
                  "1群：839372371，2群：957634136",textAlign: TextAlign.center,style: TextStyle(color: Colors.grey),),
            ],
          ),
        ),
      ),
    );
  }
  Widget buildPicker(){
    return TextButton(onPressed: ()=> _showLocationMethodPicker(), child: Row(
      children: [
        Consumer<LoginPageProvider>(
          builder: (context, provider, child) {
            return Text(
                "${provider.loginLocation.name} ${provider.loginMethod.name}");
          },
        ),
        const Icon(Icons.arrow_drop_down),
      ],
    ));
  }

  TextField buildTextField(
      String labelText, TextEditingController textEditingController,
      {obscureText = false}) {
    return TextField(
      controller: textEditingController,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    final loginLocation = Provider.of<LoginPageProvider>(context, listen: false).loginLocation;
    CumtLogin.logout(loginLocation: loginLocation).then((value) {
      _showSnackBar(context, value);
    });
  }

  void _showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showLocationMethodPicker(){
    Picker(
        adapter: PickerDataAdapter<dynamic>(pickerData: [
          CumtLoginLocationExtension.nameList,
          CumtLoginMethodExtension.nameList,
        ], isArray: true),
        changeToFirst: true,
        hideHeader: false,
        onConfirm: (Picker picker, List value) {
          final loginMethod = CumtLoginMethodExtension
              .fromName(picker.getSelectedValues()[1]);
          final loginLocation = CumtLoginLocationExtension.fromName(
              picker.getSelectedValues()[0]);
          Provider.of<LoginPageProvider>(context, listen: false)
              .setMethodLocation(loginMethod, loginLocation);
        }).showModal(context);
  }

  void _handleLogin(BuildContext context) {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();
    final loginLocation = Provider.of<LoginPageProvider>(context, listen: false).loginLocation;
    final loginMethod = Provider.of<LoginPageProvider>(context, listen: false).loginMethod;
    if (username.isEmpty || password.isEmpty) {
      _showSnackBar(context, '账号或密码不能为空');
      return;
    }

    CumtLogin.login(
            username: username,
            password: password,
            loginMethod: loginMethod,
            loginLocation:loginLocation)
        .then((value) {

      _showSnackBar(context, value);
    });
  }
}
