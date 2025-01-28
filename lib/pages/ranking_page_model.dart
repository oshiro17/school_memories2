// ranking_page_model.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../class_model.dart';

class RankingPageModel extends ChangeNotifier {
  bool isLoading = false;

  final List<String> sampleRankings = [
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
  // 'クラスで一番友達が多いのは？',
  // 'クラスで一番うるさいのは？',
  // 'クラスで一番世界を救いそうなのは？',
  // 'クラスで一番オリンピックに出てそうなのは？',
  // 'クラスで一番お母さんにしたいのは？',
  // 'クラスで一番お父さんにしたいのは？',
  // 'クラスで一番妹にしたいのは？',
  // 'クラスで一番姉にしたいのは？',
  // 'クラスで一番弟にしたいのは？',
  // 'クラスで一番兄にしたいのは？',
  // 'クラスで一番奥さんにしたいのは？',
  // 'クラスで一番旦那さんにしたいのは？',
  // 'クラスで一番アイドルになりそうなのは？',
];

  // Map<"サンプルランキング1", List<RankingVote>> など
  Map<String, List<RankingVote>> rankingVotes = {};

  // メンバーID->名前のマップ
  Map<String, String> memberNameMap = {};

  Future<void> init(String classId) async {
    try {
      isLoading = true;
      notifyListeners();

      // メンバーID->名前のマップを取得
      final memberSnap = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .get();
      for (final doc in memberSnap.docs) {
        final data = doc.data();
        final memberId = data['id'] ?? '';
        final memberName = data['name'] ?? '';
        memberNameMap[memberId] = memberName;
      }

      // sampleRankingsごとにvotesを取得し、count降順でソート
      for (final rankingName in sampleRankings) {
        final votesSnap = await FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .collection('rankings')
            .doc(rankingName)
            .collection('votes')
            .get();

        final list = votesSnap.docs.map((doc) {
          final data = doc.data();
          final memberId = doc.id;
          final count = data['count'] ?? 0;
          final memberName = memberNameMap[memberId] ?? 'unknown';
          return RankingVote(memberId, memberName, count);
        }).toList();

        // count降順
        list.sort((a, b) => b.count.compareTo(a.count));
        rankingVotes[rankingName] = list;
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class RankingVote {
  final String memberId;
  final String memberName;
  final int count;

  RankingVote(this.memberId, this.memberName, this.count);
}
