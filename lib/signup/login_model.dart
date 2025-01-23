import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginModel extends ChangeNotifier {
  String? mail;
  String? password;

  Future<void> login() async {
    if (mail == null || mail!.isEmpty || password == null || password!.isEmpty) {
      throw 'メールアドレスとパスワードを入力してください';
    }

    try {
      // Firebase Authenticationでログイン
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: mail!,
        password: password!,
      );
    } on FirebaseAuthException catch (e) {
      // Firebaseエラーのハンドリング
      switch (e.code) {
        case 'user-not-found':
          throw 'ユーザーが見つかりません';
        case 'wrong-password':
          throw 'パスワードが間違っています';
        default:
          throw 'ログインに失敗しました: ${e.message}';
      }
    }
  }
}
