import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MembersProfileModel extends ChangeNotifier {
  List<Member> classMemberList = [];
  bool isLoading = true;

  /// クラスIDを使ってクラスメンバーを取得
  Future<void> fetchClassMembers(String classId) async {
    try {
      isLoading = true;
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('classes') // クラス情報が格納されているコレクション
          .doc(classId) // クラスIDで指定
          .collection('members') // メンバー一覧のサブコレクション
          .get();

      classMemberList = snapshot.docs.map((doc) {
        final data = doc.data();
        return Member(
          name: data['name'] ?? '',
          birthday: data['birthday'] ?? '',
          subject: data['subject'] ?? '',
        );
      }).toList();

      // プロフィール未設定のメンバーを除外する（条件付き）
      classMemberList = classMemberList.where((member) {
        return member.name.isNotEmpty || member.birthday.isNotEmpty || member.subject.isNotEmpty;
      }).toList();
    } catch (e) {
      print('エラー: クラスメンバーの取得に失敗しました。$e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
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
