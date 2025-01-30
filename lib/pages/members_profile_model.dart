import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MembersProfileModel extends ChangeNotifier {
  List<Member> classMemberList = [];
  bool isLoading = false;
  bool isEmpty = true;// 一度だけ取得するフラグ

  Future<void> fetchClassMembers(String classId, String currentMemberId ) async {
   
    isLoading = true;
    notifyListeners();


    try {
      final s = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(currentMemberId)
          .get();
     if (s.exists) {
  final callme = s.data()!['callme'];
  if (callme == null || callme == '') {
    // `callme` フィールドが存在しないか、空文字列の場合
    isEmpty = true;
    isLoading = false;
    return;
  } else {
    // `callme` が空でない場合
    isEmpty = false;
    print("デバッグ: メンバーを表示");
  }
} else {
  print("まずい"); // ドキュメントが存在しない場合
  return;
}
    
      final snapshot = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .get();

      final List<Member> list = snapshot.docs.map((doc) {
        final data = doc.data();

        final id = doc.id;


        // それ以外の型なら 0 のまま

        return Member(
          id: id,
          // avatarIndex: avatarIndex,
          avatarIndex: data['avatarIndex'] ?? 0,
          name: data['name'],
          motto: data['motto'],
          futureDream: data['futureDream'],
        );
      }).toList();

      // プロフィール未設定を除外したい場合など
      classMemberList = list.where((member) {
        return member.name.isNotEmpty
            || member.motto.isNotEmpty
            || member.futureDream.isNotEmpty;
      }).toList();

    } catch (e) {
      print('エラー: クラスメンバーの取得に失敗 $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
      isLoading = false;
  }

}

/// Memberクラス
class Member {
  final String id;         // Firestore doc.id
  final int avatarIndex;   // アバター画像用のインデックス
  final String name;       // 名前
  final String motto;      // モットー
  final String futureDream;// 将来の夢等

  Member({
    required this.id,
    required this.avatarIndex,
    required this.name,
    required this.motto,
    required this.futureDream,
  });
}
