import 'package:flutter/material.dart';

class SignUpModel extends ChangeNotifier {
  String mail = '';
  String password = '';

  Future signUp() async {
    if (mail.isEmpty) {
      throw ('メールアドレスを入力してください');
    }
    if (password.isEmpty) {
      throw ('パスワードを入力してください');
    }

    // 仮の処理: Firebaseなしで成功をシミュレート
    if (mail.isNotEmpty && password.isNotEmpty) {
      print("ユーザー作成成功");
    } else {
      throw ('登録に失敗しました。メールアドレスまたはパスワードが無効です。');
    }

    // Firebase依存部分をコメントアウト
    /*
    final User user = (await _auth.createUserWithEmailAndPassword(
      email: mail,
      password: password,
    ))
        .user!;

    final email = user.email;

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      await user.reload();

      await userRef.set({
        'id': user.uid,
        'email': email,
        'name': '',
        'comment': '',
        'imageURL': '',
        'imageName': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('createUserProfile処理中のエラーです');
      print(e.toString());
      throw ('エラーが発生しました。\nもう一度お試し下さい。');
    }
    */

    notifyListeners();
  }
}
