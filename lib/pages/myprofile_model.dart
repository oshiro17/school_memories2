import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfileModel extends ChangeNotifier {
  // Q形式に変更 (合計25項目 + avatarIndex + isLoading)
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
  String name = '';
  int avatarIndex = 0;
  bool isLoading = false;

  Future<void> fetchProfileOnce(String classId, String memberId) async {
    isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'profile_${classId}_$memberId';
    final cachedProfile = prefs.getString(cacheKey);

    bool needsFetchFromFirebase = true;

    if (cachedProfile != null) {
      final cachedData = json.decode(cachedProfile);
      _loadProfileFromJson(cachedData);

      // q1 が空でない場合はキャッシュを使用
      if (q1.isNotEmpty) {
        needsFetchFromFirebase = false;
      }
    }

    if (needsFetchFromFirebase) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .collection('members')
            .doc(memberId)
            .get();

        if (doc.exists) {
          final data = doc.data();
          _loadProfileFromJson(data);

          // データをキャッシュに保存
          await prefs.setString(cacheKey, json.encode(data));
        }
      } catch (e) {
        print('fetchProfileエラー: $e');
      }
    }

    isLoading = false;
    notifyListeners();
  }

  void _loadProfileFromJson(Map<String, dynamic>? data) {
    // Firestoreのフィールド名も q1〜q25 に合わせる
    q1 = data?['q1'] ?? '';
    q2 = data?['q2'] ?? '';
    q3 = data?['q3'] ?? '';
    q4 = data?['q4'] ?? '';
    q5 = data?['q5'] ?? '';
    q6 = data?['q6'] ?? '';
    q7 = data?['q7'] ?? '';
    q8 = data?['q8'] ?? '';
    q9 = data?['q9'] ?? '';
    q10 = data?['q10'] ?? '';
    q11 = data?['q11'] ?? '';
    q12 = data?['q12'] ?? '';
    q13 = data?['q13'] ?? '';
    q14 = data?['q14'] ?? '';
    q15 = data?['q15'] ?? '';
    q16 = data?['q16'] ?? '';
    q17 = data?['q17'] ?? '';
    q18 = data?['q18'] ?? '';
    q19 = data?['q19'] ?? '';
    q20 = data?['q20'] ?? '';
    q21 = data?['q21'] ?? '';
    q22 = data?['q22'] ?? '';
    q23 = data?['q23'] ?? '';
    q24 = data?['q24'] ?? '';
    q25 = data?['q25'] ?? '';
    q26 = data?['q26'] ?? '';
    q27 = data?['q27'] ?? '';
    q28 = data?['q28'] ?? '';
    q29 = data?['q29'] ?? '';
    name = data?['name'] ?? '';
    avatarIndex = data?['avatarIndex'] ?? 0;
  }
}
