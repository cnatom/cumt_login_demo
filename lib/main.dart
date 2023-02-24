import 'package:cumt_login_demo/login.dart';
import 'package:flutter/material.dart';

main() {
  runApp(MaterialApp(
    home: LoginPage(),
  ));
}

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  CumtLoginMethod loginMethod = CumtLoginMethod.cumt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cumt校园网登录'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildDropdownButton(),
              const SizedBox(height: 16.0),
              buildTextField("账号", _usernameController),
              const SizedBox(height: 16.0),
              buildTextField("密码", _passwordController,obscureText: true),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () => _handleLogin(context),
                    child: const Text('登录'),
                  ),
                  OutlinedButton(
                    onPressed: () => _handleLogout(context),
                    child: const Text('注销'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  TextField buildTextField(
      String labelText, TextEditingController textEditingController,{obscureText = false}) {
    return TextField(
      controller: textEditingController,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  DropdownButton<String> buildDropdownButton() {
    return DropdownButton<String>(
      value: loginMethod.name,
      // Default value
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(color: Colors.black),
      onChanged: (String? newValue) {
        setState(() {
          loginMethod = CumtLoginMethod.values
              .firstWhere((element) => element.name == newValue);
        });
      },
      items: CumtLoginMethod.values
          .map<DropdownMenuItem<String>>((CumtLoginMethod value) {
        return DropdownMenuItem<String>(
          value: value.name,
          child: Text(value.name),
        );
      }).toList(),
    );
  }
  
  void _handleLogout(BuildContext context) {
    CumtLogin.logout().then((value) {
      showSnackBar(context, value);
    });
  }

  void showSnackBar(BuildContext context,String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 2),
      ),
    );
  }


  void _handleLogin(BuildContext context) {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();
    if (username.isEmpty || password.isEmpty) {
      showSnackBar(context, '账号或密码不能为空');
      return;
    }
    CumtLogin.login(
            username: username, password: password, loginMethod: loginMethod)
        .then((value) {
          showSnackBar(context, value);
    });
  }
}
