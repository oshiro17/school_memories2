import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'signup_model.dart';

class SignupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mailController = TextEditingController();
    final passwordController = TextEditingController();

    return ChangeNotifierProvider<SignUpModel>(
      create: (_) => SignUpModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<SignUpModel>(
          builder: (context, model, child) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 50),
                    const Text(
                      "卒業文集へようこそ",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Sign up to get started!",
                      style: TextStyle(fontSize: 20, color: Colors.blue),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Email ID",
                        labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w600),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      controller: mailController,
                      onChanged: (text) => model.mail = text,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w600),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      obscureText: true,
                      controller: passwordController,
                      onChanged: (text) => model.password = text,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await model.signUp();
                            // 登録完了したら、popして RootPage へ戻る → 参加クラスチェック
                            Navigator.of(context).pop();
                          } catch (e) {
                            _showDialog(context, e.toString());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          "新規登録",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "すでにアカウントをお持ちですか？  ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Text(
                            "ログイン",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('エラー'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}