import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyProfileModel extends ChangeNotifier {
  // プロフィール情報
  String name = '';
  String birthday = '';
  String subject = '';
  String comment = '';
  String imageURL = '';

  final currentUser = FirebaseAuth.instance.currentUser; // ログイン中のユーザー

  /// 初期化処理
  Future<void> init(BuildContext context) async {
    if (currentUser == null) {
      return; // ログインしていない場合は何もしない
    }

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);

    try {
      final userDoc = await userRef.get();
      if (userDoc.exists) {
        // Firestore からデータを取得してフィールドにセット
        final data = userDoc.data() as Map<String, dynamic>;
        name = data['name'] ?? '';
        birthday = data['birthday'] ?? '';
        subject = data['subject'] ?? '';
        comment = data['comment'] ?? '';
        imageURL = data['imageURL'] ?? '';
        notifyListeners(); // UI を更新
      }
    } catch (e) {
      print('プロフィール情報の取得に失敗しました: $e');
    }
  }

  /// プロフィール情報を更新
  Future<void> updateProfile({
    required String name,
    required String birthday,
    required String subject,
    String? comment,
    String? imageURL,
  }) async {
    if (currentUser == null) {
      return; // ログインしていない場合は何もしない
    }

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);

    try {
      // Firestore にデータを更新
      await userRef.update({
        'name': name,
        'birthday': birthday,
        'subject': subject,
        if (comment != null) 'comment': comment,
        if (imageURL != null) 'imageURL': imageURL,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // ローカルモデルを更新
      this.name = name;
      this.birthday = birthday;
      this.subject = subject;
      if (comment != null) this.comment = comment;
      if (imageURL != null) this.imageURL = imageURL;

      notifyListeners(); // UI を更新
    } catch (e) {
      print('プロフィール情報の更新に失敗しました: $e');
    }
  }
}
