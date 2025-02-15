// members_profile_model.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Member {
  final String id;
  final int avatarIndex;
  final String name;
  final String motto;
  final String futureDream;
  final String q1;
  final String q2;
  final String q3;
  final String q4;
  final String q5;
  final String q6;
  final String q7;
  final String q8;
  final String q9;
  final String q10;
  final String q11;
  final String q12;
  final String q13;
  final String q14;
  final String q15;
  final String q16;
  final String q17;
  final String q18;
  final String q19;
  final String q20;
  final String q21;
  final String q22;
  final String q23;
  final String q24;
  final String q25;
  final String q26;
  final String q27;
  final String q30;
  final String q31;
  final String q32;
  final String q33;

  Member({
    required this.id,
    required this.avatarIndex,
    required this.name,
    required this.motto,
    required this.futureDream,
    required this.q1,
    required this.q2,
    required this.q3,
    required this.q4,
    required this.q5,
    required this.q6,
    required this.q7,
    required this.q8,
    required this.q9,
    required this.q10,
    required this.q11,
    required this.q12,
    required this.q13,
    required this.q14,
    required this.q15,
    required this.q16,
    required this.q17,
    required this.q18,
    required this.q19,
    required this.q20,
    required this.q21,
    required this.q22,
    required this.q23,
    required this.q24,
    required this.q25,
    required this.q26,
    required this.q27,
    required this.q30,
    required this.q31,
    required this.q32,
    required this.q33,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] ?? '',
      avatarIndex: json['avatarIndex'] ?? 0,
      name: json['name'] ?? '',
      motto: json['q29'] ?? '',
      futureDream: json['q28'] ?? '',
      q1: json['q1'] ?? '',
      q2: json['q2'] ?? '',
      q3: json['q3'] ?? '',
      q4: json['q4'] ?? '',
      q5: json['q5'] ?? '',
      q6: json['q6'] ?? '',
      q7: json['q7'] ?? '',
      q8: json['q8'] ?? '',
      q9: json['q9'] ?? '',
      q10: json['q10'] ?? '',
      q11: json['q11'] ?? '',
      q12: json['q12'] ?? '',
      q13: json['q13'] ?? '',
      q14: json['q14'] ?? '',
      q15: json['q15'] ?? '',
      q16: json['q16'] ?? '',
      q17: json['q17'] ?? '',
      q18: json['q18'] ?? '',
      q19: json['q19'] ?? '',
      q20: json['q20'] ?? '',
      q21: json['q21'] ?? '',
      q22: json['q22'] ?? '',
      q23: json['q23'] ?? '',
      q24: json['q24'] ?? '',
      q25: json['q25'] ?? '',
      q26: json['q26'] ?? '',
      q27: json['q27'] ?? '',
      q30: json['q30'] ?? '',
      q31: json['q31'] ?? '',
      q32: json['q32'] ?? '',
      q33: json['q33'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'avatarIndex': avatarIndex,
      'name': name,
      'q29': motto,
      'q28': futureDream,
      'q1': q1,
      'q2': q2,
      'q3': q3,
      'q4': q4,
      'q5': q5,
      'q6': q6,
      'q7': q7,
      'q8': q8,
      'q9': q9,
      'q10': q10,
      'q11': q11,
      'q12': q12,
      'q13': q13,
      'q14': q14,
      'q15': q15,
      'q16': q16,
      'q17': q17,
      'q18': q18,
      'q19': q19,
      'q20': q20,
      'q21': q21,
      'q22': q22,
      'q23': q23,
      'q24': q24,
      'q25': q25,
      'q26': q26,
      'q27': q27,
      'q30': q30,
      'q31': q31,
      'q32': q32,
      'q33': q33,
    };
  }
}

class MembersProfileModel extends ChangeNotifier {
  List<Member> classMemberList = [];
  bool isLoading = false;
  bool isEmpty = true;
  String? errorMessage; // エラー状態

  Future<void> fetchClassMembers(
    String classId,
    String currentMemberId, {
    bool forceRefresh = false,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cachedData = prefs.getString('classMembers_$classId');
      if (cachedData != null) {
        try {
          final List<dynamic> decodedList = jsonDecode(cachedData);
          // キャッシュから読み込んだリストのうち、motto が空でないものだけ採用
          classMemberList = decodedList
              .map((json) => Member.fromJson(json))
              .where((member) => member.motto.trim().isNotEmpty)
              .toList();
          isEmpty = classMemberList.isEmpty;
          // 先に画面に反映
          notifyListeners();
        } catch (e) {
          if (kDebugMode) {
            print('キャッシュのパースに失敗: $e');
          }
        }
      }
    }

    try {
      // 現在ユーザーのドキュメントを取得
      final doc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(currentMemberId)
          .get();

      if (!doc.exists) {
        errorMessage = "エラー: ドキュメントが存在しません";
        isEmpty = true;
        return;
      }

      final dataCurrentUser = doc.data()!;
      final callme = dataCurrentUser['q1'] ?? '';
      if (callme.isEmpty) {
        isEmpty = true;
        return;
      } else {
        isEmpty = false;
      }

      // ★ 追加: blockedList を取得 (ない場合は空リスト)
      final blockedListDynamic = dataCurrentUser['blockedList'] as List<dynamic>?; 
      final blockedList = blockedListDynamic?.map((e) => e.toString()).toList() ?? [];

      // クラス内の全メンバーをまとめて取得
      final snapshot = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .get();

      List<Member> membersTemp = [];
      for (var doc in snapshot.docs) {
        try {
          // すでに doc.data() があるが、念のため再取得したい場合は下記
          final memberDoc = await doc.reference.get();
          if (!memberDoc.exists) continue;

          final data = memberDoc.data() as Map<String, dynamic>;
          final memberId = memberDoc.id;

          // ★ ブロックリストに含まれる相手は除外
          if (blockedList.contains(memberId)) {
            continue;
          }

          // motto が空ならスキップ
          final mottoData = data['q29'] ?? '';
          if (mottoData.toString().trim().isEmpty) {
            continue;
          }

          final member = Member(
            id: memberId,
            avatarIndex: data['avatarIndex'] ?? 0,
            name: data['name'] ?? '',
            motto: data['q29'] ?? '',
            futureDream: data['q28'] ?? '',
            q1: data['q1'] ?? '',
            q2: data['q2'] ?? '',
            q3: data['q3'] ?? '',
            q4: data['q4'] ?? '',
            q5: data['q5'] ?? '',
            q6: data['q6'] ?? '',
            q7: data['q7'] ?? '',
            q8: data['q8'] ?? '',
            q9: data['q9'] ?? '',
            q10: data['q10'] ?? '',
            q11: data['q11'] ?? '',
            q12: data['q12'] ?? '',
            q13: data['q13'] ?? '',
            q14: data['q14'] ?? '',
            q15: data['q15'] ?? '',
            q16: data['q16'] ?? '',
            q17: data['q17'] ?? '',
            q18: data['q18'] ?? '',
            q19: data['q19'] ?? '',
            q20: data['q20'] ?? '',
            q21: data['q21'] ?? '',
            q22: data['q22'] ?? '',
            q23: data['q23'] ?? '',
            q24: data['q24'] ?? '',
            q25: data['q25'] ?? '',
            q26: data['q26'] ?? '',
            q27: data['q27'] ?? '',
            q30: data['q30'] ?? '',
            q31: data['q31'] ?? '',
            q32: data['q32'] ?? '',
            q33: data['q33'] ?? '',
          );
          membersTemp.add(member);

          // 取得できたらすぐ反映
          classMemberList = List.from(membersTemp);
          isEmpty = classMemberList.isEmpty;
          notifyListeners();
        } catch (e) {
          if (kDebugMode) {
            print('メンバー取得失敗: $e');
          }
          // 個々の取得エラーは無視して続行
        }
      }

      // キャッシュ更新
      try {
        final encodedData = jsonEncode(
          classMemberList.map((m) => m.toJson()).toList(),
        );
        await prefs.setString('classMembers_$classId', encodedData);
      } catch (e) {
        if (kDebugMode) {
          print('キャッシュ更新に失敗: $e');
        }
      }
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        errorMessage = 'ネットワークエラーです。';
      } else {
        errorMessage = 'Firestoreエラー: ${e.message}';
      }
    } catch (e) {
      errorMessage = 'クラスメンバーの取得に失敗しました: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
