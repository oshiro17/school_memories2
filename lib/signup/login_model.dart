import 'package:flutter/material.dart';

class LoginModel extends ChangeNotifier {
  String mail = '';
  String password = '';

  Future<void> login() async {
    if (mail.isEmpty) {
      throw ('メールアドレスを入力してください');
    }
    if (password.isEmpty) {
      throw ('パスワードを入力してください');
    }

    // ダミーログイン処理
    if (mail == 'test.com' && password == '123456') {
      print('ログイン成功');
    } else {
      throw ('ログインに失敗しました');
    }

    notifyListeners();
  }
}
