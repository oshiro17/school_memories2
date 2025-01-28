import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyProfileModel extends ChangeNotifier {
  // プロフィールデータのプロパティ
  String name = '';
  String birthday = '';
  String subject = '';
  bool isLoading = true;

  /// 初期化処理（データ取得を行う）
  Future<void> init(String classId, String memberId) async {
    await fetchProfile(classId, memberId);
  }

  /// Firestoreからメンバーのプロフィールを取得してモデルに反映
  Future<void> fetchProfile(String classId, String memberId) async {
    try {
      isLoading = true;
      notifyListeners(); // ローディング状態を通知

      // Firestoreからメンバードキュメントを取得
      final doc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(memberId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        name = data?['name'] ?? ''; // Firestoreのnameフィールドを取得
        birthday = data?['birthday'] ?? ''; // Firestoreのbirthdayフィールドを取得
        subject = data?['subject'] ?? ''; // Firestoreのsubjectフィールドを取得
        print('プロフィールデータ取得成功: name=$name, birthday=$birthday, subject=$subject');
      } else {
        print('メンバードキュメントが存在しません: classId=$classId, memberId=$memberId');
      }
    } catch (e) {
      print('fetchProfileエラー: $e');
    } finally {
      isLoading = false;
      notifyListeners(); // ローディング解除を通知
    }
  }
}