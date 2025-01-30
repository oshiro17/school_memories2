import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MembersProfileModel extends ChangeNotifier {
  List<Member> classMemberList = [];
  bool isLoading = false;
  bool isFetched = false; // 一度だけ取得するフラグ

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

        // -- 安全に型変換 or デフォルト値をセットする --
        // doc.id は必ず string なので null にはならない想定
        final id = doc.id;

        // avatarIndex を int に変換（Firestoreで string や null の可能性も考慮）
        final dynamic rawAvatarIndex = data['avatarIndex'];
        int avatarIndex = 0;
        if (rawAvatarIndex is int) {
          avatarIndex = rawAvatarIndex;
        } else if (rawAvatarIndex is String) {
          avatarIndex = int.tryParse(rawAvatarIndex) ?? 0;
        } 
        // それ以外の型なら 0 のまま

        // name, motto, futureDream を string に安全変換
        final dynamic rawName = data['name'];
        final name = (rawName is String) ? rawName : '';

        final dynamic rawMotto = data['motto'];
        final motto = (rawMotto is String) ? rawMotto : '';

        final dynamic rawFutureDream = data['futureDream'];
        final futureDream = (rawFutureDream is String) ? rawFutureDream : '';

        return Member(
          id: id,
          // avatarIndex: avatarIndex,
          avatarIndex: 0,
          name: name,
          motto: motto,
          futureDream: futureDream,
        );
      }).toList();

      // プロフィール未設定を除外したい場合など
      classMemberList = list.where((member) {
        return member.name.isNotEmpty
            || member.motto.isNotEmpty
            || member.futureDream.isNotEmpty;
      }).toList();

      isFetched = true;
    } catch (e) {
      print('エラー: クラスメンバーの取得に失敗 $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void resetFetchedFlag() {
    isFetched = false;
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
