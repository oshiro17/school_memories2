// profile_cache.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileCache extends ChangeNotifier {
  bool isFetched = false; // 自分のプロフィールを取得済みかどうか
  Map<String, dynamic>? myProfileData; // Firestoreから取得した自分のプロフィール情報

  /// 自分のプロフィールを一度だけFirestoreから取得
  Future<void> fetchMyProfileOnce({
    required String classId,
    required String memberId,
  }) async {
    // すでに取得していたら何もしない
    if (isFetched) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(memberId)
          .get();

      if (doc.exists) {
        myProfileData = doc.data();
        isFetched = true;
        notifyListeners();
      } else {
        print('メンバーが存在しません。classId=$classId, memberId=$memberId');
      }
    } catch (e) {
      print('プロフィール取得エラー: $e');
    }
  }
}
