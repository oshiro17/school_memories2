import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RankingPageModel extends ChangeNotifier {
  bool isLoading = false;

  /// コード中だけで持つランキング用の設問
  final List<String> questionList = [
    'クラスで一番モテるのは？',
  'クラスで一番おしゃべりなのは？',
  'クラスで一番頭がいいのは？',
  'クラスで一番妄想が激しいのは？',
  'クラスで一番結婚が早そうなのは？',
  'クラスで一番お金持ちになりそうなのは？',
  'クラスで一番海外に住みそうなのは？',
  'クラスで一番有名になりそうなのは？',
  'クラスで一番会社の社長になりそうなのは？',
  'クラスで一番世界一周しそうなのは？',
  'クラスで一番すぐ結婚しそうなのは？',
  'クラスで一番忘れ物が多いのは？',
  'クラスで一番優しいのは？',
  'クラスで一番イケメンなのは？',
  'クラスで一番可愛いのは？',
    // ...etc
  ];

  /// 表示用に, 質問インデックス => [ (memberName, count), (memberName, count)... ] のように保持
  Map<int, List<_RankingVote>> rankingVotes = {};

  // メンバーID => メンバー名のマップ
  Map<String, String> memberNameMap = {};

  Future<void> init(String classId) async {
    try {
      isLoading = true;
      notifyListeners();

      // メンバーID->名前をまとめて取得
      final memberSnap = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .get();
      memberNameMap = {
        for (final doc in memberSnap.docs)
          doc.id: doc.data()['name'] ?? 'unknown'
      };

      // 0..questionList.length-1 について votesを読み込む
      for (int i = 0; i < questionList.length; i++) {
        final docId = i.toString();
        final votesSnap = await FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .collection('rankings')
            .doc(docId)
            .collection('votes')
            .get();

        final list = votesSnap.docs.map((doc) {
          final count = doc.data()['count'] ?? 0;
          final memberId = doc.id;
          final memberName = memberNameMap[memberId] ?? 'unknown';
          return _RankingVote(memberName, count);
        }).toList();

        // count降順でソート
        list.sort((a, b) => b.count.compareTo(a.count));
        rankingVotes[i] = list;
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class _RankingVote {
  final String memberName;
  final int count;

  _RankingVote(this.memberName, this.count);
}
