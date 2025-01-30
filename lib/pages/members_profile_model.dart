import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MembersProfileModel extends ChangeNotifier {
  List<Member> classMemberList = [];
  bool isLoading = false;

  // 一度だけ取得するフラグ（必要なら）
  bool isFetched = false;

  Future<void> fetchClassMembers(String classId, {bool forceUpdate = false}) async {
    if (isFetched && !forceUpdate) {
      // すでに取得済みで、強制リロードでなければスキップ
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .get();

      final List<Member> list = snapshot.docs.map((doc) {
        final data = doc.data();
        return Member(
          name: data['name'] ?? '',
          birthday: data['motto'] ?? '',
          subject: data['futureDream'] ?? '',
        );
      }).toList();

      // プロフィール未設定を除外したい場合など
      classMemberList = list.where((member) {
        return member.name.isNotEmpty || member.birthday.isNotEmpty || member.subject.isNotEmpty;
      }).toList();

      isFetched = true;
    } catch (e) {
      print('エラー: クラスメンバーの取得に失敗 $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 必要なら「フラグリセット」用メソッド
  void resetFetchedFlag() {
    isFetched = false;
  }
}

class Member {
  final String name;
  final String birthday;
  final String subject;
  Member({
    required this.name,
    required this.birthday,
    required this.subject,
  });
}
