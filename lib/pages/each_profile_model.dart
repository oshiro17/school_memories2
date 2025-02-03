import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EachProfileModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage; // エラー状態を保持するフィールド

  // Firestoreから取得したいデータをフィールドとして定義
  int avatarIndex = 0;
  String name = '';
  String q1 = '';
  String q2 = '';
  String q3 = '';
  String q4 = '';
  String q5 = '';
  String q6 = '';
  String q7 = '';
  String q8 = '';
  String q9 = '';
  String q10 = '';
  String q11 = '';
  String q12 = '';
  String q13 = '';
  String q14 = '';
  String q15 = '';
  String q16 = '';
  String q17 = '';
  String q18 = '';
  String q19 = '';
  String q20 = '';
  String q21 = '';
  String q22 = '';
  String q23 = '';
  String q24 = '';
  String q25 = '';
  String q26 = '';
  String q27 = '';
  String q28 = '';
  String q29 = '';

  /// Firestoreから [memberID] に対応するメンバー情報を取得
  Future<void> fetchProfile(String memberID, String classId) async {
    isLoading = true;
    errorMessage = null; // 処理開始時にエラー状態をリセット
    notifyListeners();

    try {
      final doc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(memberID)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        // それぞれのフィールドに代入
        avatarIndex = data['avatarIndex'] ?? 0;
        name = data['name'] ?? '';
        q1 = data['q1'] ?? '';
        q2 = data['q2'] ?? '';
        q3 = data['q3'] ?? '';
        q4 = data['q4'] ?? '';
        q5 = data['q5'] ?? '';
        q6 = data['q6'] ?? '';
        q7 = data['q7'] ?? '';
        q8 = data['q8'] ?? '';
        q9 = data['q9'] ?? '';
        q10 = data['q10'] ?? '';
        q11 = data['q11'] ?? '';
        q12 = data['q12'] ?? '';
        q13 = data['q13'] ?? '';
        q14 = data['q14'] ?? '';
        q15 = data['q15'] ?? '';
        q16 = data['q16'] ?? '';
        q17 = data['q17'] ?? '';
        q18 = data['q18'] ?? '';
        q19 = data['q19'] ?? '';
        q20 = data['q20'] ?? '';
        q21 = data['q21'] ?? '';
        q22 = data['q22'] ?? '';
        q23 = data['q23'] ?? '';
        q24 = data['q24'] ?? '';
        q25 = data['q25'] ?? '';
        q26 = data['q26'] ?? '';
        q27 = data['q27'] ?? '';
        q28 = data['q28'] ?? '';
        q29 = data['q29'] ?? '';
      } else {
        // ドキュメントが存在しない場合のエラー設定
        errorMessage = '該当するプロフィールが見つかりませんでした。';
      }
    } on FirebaseException catch (e) {
      errorMessage = 'Firestoreエラー: ${e.message}';
    } catch (e) {
      errorMessage = 'プロフィール取得中にエラーが発生しました: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
