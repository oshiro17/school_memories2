import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_memories2/signup/class_list_page.dart';
import 'package:school_memories2/signup/class_selection_page_model.dart';
import 'signup/login_page.dart';


class RootPage extends StatelessWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // FirebaseAuth のログイン状態を監視
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 読み込み中
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // user == null → 未ログイン
        if (!snapshot.hasData) {
          return LoginPage();
        }

        // ログイン中ユーザーの uid を取得
        final user = snapshot.data!;
        return FutureBuilder<bool>(
          future: _hasClasses(user.uid),
          builder: (context, snapshot2) {
            if (snapshot2.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot2.hasError) {
              return Scaffold(
                body: Center(child: Text('エラーが発生しました: ${snapshot2.error}')),
              );
            }

            // 参加クラスが1件以上あるかどうか
            final hasClasses = snapshot2.data ?? false;
            if (hasClasses) {
              // 参加クラスあり → クラス一覧ページへ
              return ClassListPage();
            } else {
              // 参加クラスなし → クラス作成/参加ページへ
              return ClassSelectionPage();
            }
          },
        );
      },
    );
  }

  /// ユーザーが参加中のクラスが1件以上あるかどうかを確認するメソッド
  Future<bool> _hasClasses(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('attendingClasses')
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}
