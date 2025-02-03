import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MembersProfileModel extends ChangeNotifier {
  List<Member> classMemberList = [];
  bool isLoading = false;
  bool isEmpty = true;
  String? errorMessage; // エラー状態を保持するフィールド

  /// クラスメンバーを取得（Firestoreからまたはキャッシュから）
Future<void> fetchClassMembers(String classId, String currentMemberId, {bool forceRefresh = false}) async {
  isLoading = true;
  errorMessage = null;
  notifyListeners();

  try {
    final prefs = await SharedPreferences.getInstance();
    if (!forceRefresh) {
      final cachedData = prefs.getString('classMembers_$classId');
      if (cachedData != null) {
        final List<dynamic> decodedList = jsonDecode(cachedData);
        classMemberList = decodedList.map((json) => Member.fromJson(json)).toList();
        isEmpty = classMemberList.isEmpty;
        isLoading = false;
        notifyListeners();
        return;
      }
    }

    await _fetchFromFirestore(classId, currentMemberId, prefs);
  } on FirebaseException catch (e) {
    if (e.code == 'unavailable') {
      errorMessage = 'ネットワークエラーです。';
      // 必要に応じて、navigatorKey.currentState?.pushAndRemoveUntil(...) で OfflinePage に遷移させてもよい
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


  /// Firestoreからデータを取得し、SharedPreferencesに保存
  Future<void> _fetchFromFirestore(String classId, String currentMemberId, SharedPreferences prefs) async {
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

    final callme = doc.data()?['q1'];
    if (callme == null || callme.isEmpty) {
      isEmpty = true;
      return;
    } else {
      isEmpty = false;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('classes')
        .doc(classId)
        .collection('members')
        .get();

    final List<Member> list = snapshot.docs.map((doc) {
      final data = doc.data();
      return Member(
        id: doc.id,
        avatarIndex: data['avatarIndex'] ?? 0,
        name: data['name'] ?? '',
        motto: data['q29'] ?? '',
        futureDream: data['q28'] ?? '',
      );
    }).toList();

    // 空のフィールドを持つメンバーを除外
    classMemberList = list.where((member) {
      return member.name.isNotEmpty || member.motto.isNotEmpty || member.futureDream.isNotEmpty;
    }).toList();

    // SharedPreferencesに保存（JSON形式で保存）
    final String encodedData = jsonEncode(classMemberList.map((member) => member.toJson()).toList());
    await prefs.setString('classMembers_$classId', encodedData);
  }
}

/// Memberクラス
class Member {
  final String id;
  final int avatarIndex;
  final String name;
  final String motto;
  final String futureDream;

  Member({
    required this.id,
    required this.avatarIndex,
    required this.name,
    required this.motto,
    required this.futureDream,
  });

  // JSONからMemberインスタンスを生成
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      avatarIndex: json['avatarIndex'],
      name: json['name'],
      motto: json['q29'],
      futureDream: json['q28'],
    );
  }

  // MemberインスタンスをJSON形式に変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'avatarIndex': avatarIndex,
      'name': name,
      'q29': motto,
      'q28': futureDream,
    };
  }
}
