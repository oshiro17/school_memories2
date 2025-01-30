import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RankingPageModel extends ChangeNotifier {
  bool isLoading = false;

  final List<String> questionList = [
    'クラスで一番モテるのは？',
    'クラスで一番おしゃべりなのは？',
    'クラスで一番頭がいいのは？',
    // ...以下省略...
  ];

  // 質問index => List<RankingVote>
  Map<int, List<RankingVote>> rankingVotes = {};

  Future<void> init(String classId) async {
    try {
      isLoading = true;
      notifyListeners();

      for (int i = 0; i < questionList.length; i++) {
        final docId = i.toString();

        // /rankings/{docId}/votes 以下を取得
        final votesSnap = await FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .collection('rankings')
            .doc(docId)
            .collection('votes')
            .get();

        // それぞれのvoteDocに { count, avatarIndex, memberName } が入っている
        final votes = votesSnap.docs.map((voteDoc) {
          final data = voteDoc.data() as Map<String, dynamic>;
          final count = data['count'] ?? 0;
          final avatarIndex = data['avatarIndex'] ?? 0;
          final memberName = data['memberName'] ?? 'unknown';

          return RankingVote(
            memberName: memberName,
            count: count,
            avatarIndex: avatarIndex,
          );
        }).toList();

        // 得票数でソート (降順)
        votes.sort((a, b) => b.count.compareTo(a.count));
        rankingVotes[i] = votes;
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

/// ランキング表示用
class RankingVote {
  final String memberName;
  final int count;
  final int avatarIndex;

  RankingVote({
    required this.memberName,
    required this.count,
    required this.avatarIndex,
  });
}
