import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_model.dart';
import 'signup.dart';
import 'class_selection.dart';

void main() async {
  runApp(FirstRoute());
}

class FirstRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mailController = TextEditingController();
    final passwordController = TextEditingController();
    return ChangeNotifierProvider<LoginModel>(
      create: (_) => LoginModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<LoginModel>(
          builder: (context, model, child) {
            return SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 50),
                        Text(
                          "卒業文集へようこそ",
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "すでにアカウントをお持ちの方",
                          style: TextStyle(
                              fontSize: 20, color: Colors.blue),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        TextField(
                          decoration: InputDecoration(
                            labelText: "Email ID",
                            labelStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w600),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                          ),
                          controller: mailController,
                          onChanged: (text) {
                            model.mail = text;
                          },
                        ),
                        SizedBox(height: 16),
                        TextField(
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w600),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                          ),
                          obscureText: true,
                          controller: passwordController,
                          onChanged: (text) {
                            model.password = text;
                          },
                        ),
                        SizedBox(height: 30),
                        Container(
                          height: 50,
                          color: Colors.blue,
                          child: TextButton(
                            onPressed: () async {
                              try {
                                await model.login();
                                await _showDialog(context, 'ログインしました');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ClassselectionPage()),
                                );
                              } catch (e) {
                                _showDialog(context, e.toString());
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              constraints: BoxConstraints(
                                  minHeight: 50, maxWidth: double.infinity),
                              child: Text(
                                "ログイン",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        SizedBox(height: 30),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "初めてお使いの方はこちら",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(

                                  builder: (context) => SignupPage(),
                                ),
                              );
                            },
                            child: Text(
                              "新規登録",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future _showDialog(
    BuildContext context,
    String title,
  ) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
