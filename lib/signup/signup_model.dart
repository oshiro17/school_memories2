import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpModel extends ChangeNotifier {
  String? mail;
  String? password;

  Future<void> signUp() async {
    if (mail == null || mail!.isEmpty || password == null || password!.isEmpty) {
      throw 'メールアドレスとパスワードを入力してください。';
    }
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: mail!.trim(),
        password: password!.trim(),
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw 'このメールアドレスはすでに使用されています。';
        case 'weak-password':
          throw 'パスワードが弱すぎます。';
        case 'invalid-email':
          throw '無効なメールアドレスです。';
        default:
          throw '登録に失敗しました: ${e.message}';
      }
    }
  }
}