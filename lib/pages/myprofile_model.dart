import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyProfileModel extends ChangeNotifier {
  // プロフィールデータ
  String callme = '内緒';
  String name = '内緒';
  String birthday = '内緒';
  String subject = '内緒';
  bool isLoading = true;

  // 追加: アバター番号 (Firestore から取得)
  int avatarIndex = 0; // デフォルト0

  /// 初期化: プロフィール取得など
  Future<void> init(String classId, String memberId) async {
    await fetchProfile(classId, memberId);
  }

  /// Firestoreからメンバーのプロフィールを取得
  Future<void> fetchProfile(String classId, String memberId) async {
    try {
      isLoading = true;
      notifyListeners();

      final doc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(memberId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        callme = data?['callme'] ?? '';
        name = data?['name'] ?? '';
        birthday = data?['birthday'] ?? '';
        subject = data?['subject'] ?? '';

        // 追加: avatarIndex (Firestore上未設定の場合は 0)
        avatarIndex = data?['avatarIndex'] ?? 0;
      } else {
        print('メンバードキュメントが存在しません: classId=$classId, memberId=$memberId');
      }
    } catch (e) {
      print('fetchProfileエラー: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
