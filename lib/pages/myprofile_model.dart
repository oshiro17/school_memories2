import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyProfileModel extends ChangeNotifier {
  // プロフィールデータのプロパティ
  String name = '';
  String birthday = '';
  String subject = '';
  bool isLoading = true;

  /// 初期化処理（データ取得を行う）
  Future<void> init(BuildContext context) async {
    await fetchProfile();
  }

  /// Firestoreから自分のプロフィールを取得してモデルに反映
  Future<void> fetchProfile() async {
    try {
      isLoading = true;
      notifyListeners(); // ローディング状態を通知

      // ログイン中のユーザーのUIDを取得
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        print('ログインしていません');
        return;
      }

      // Firestoreからユーザードキュメントを取得
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        name = data?['name'] ?? ''; // Firestoreのnameフィールドを取得
        birthday = data?['birthday'] ?? ''; // Firestoreのbirthdayフィールドを取得
        subject = data?['subject'] ?? ''; // Firestoreのsubjectフィールドを取得
        print('プロフィールデータ取得成功: name=$name, birthday=$birthday, subject=$subject');
      } else {
        print('ユーザードキュメントが存在しません: uid=$uid');
      }
    } catch (e) {
      print('fetchProfileエラー: $e');
    } finally {
      isLoading = false;
      notifyListeners(); // ローディング解除を通知
    }
  }
}
