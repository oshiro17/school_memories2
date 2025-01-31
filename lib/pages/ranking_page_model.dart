import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RankingPageModel extends ChangeNotifier {
  bool isLoading = false;
  bool isVoted = false; // Firestoreから取得して、trueならランキングを表示

  final List<String> questionList = [
    '1番モテるのは？',
    '1番おしゃべりなのは？',
    '1番頭がいいのは？',
    '1番妄想が激しいのは？',
    '1番結婚が早そうなのは？',
    '1番お金持ちになりそうなのは？',
    '1番海外に住みそうなのは？',
    '1番有名になりそうなのは？',
    '1番会社の社長になりそうなのは？',
    '1番世界一周しそうなのは？',
    '1番すぐ結婚しそうなのは？',
    '1番忘れ物が多いのは？',
    '1番優しいのは？',
    '1番美人なのは？',
    '1番可愛いのは？',
    '1番友達が多いのは？',
    '1番うるさいのは？',
    '1番世界を救いそうなのは？',
    '1番オリンピックに出てそうなのは？',
    '1番お母さんにしたいのは？',
    '1番お父さんにしたいのは？',
    '1番妹にしたいのは？',
    '1番姉にしたいのは？',
    '1番弟にしたいのは？',
    '1番兄にしたいのは？',
    '1番奥さんにしたいのは？',
    '1番旦那さんにしたいのは？',
    '1番「王子様」っぽいのは？',
    '1番「お姫様」っぽいのは？',
    '1番アイドルになりそうなのは？',
  ];

  /// 質問index => List<RankingVote>
  Map<int, List<RankingVote>> rankingVotes = {};

  /// FirestoreからisVoted判定 & ランキング情報取得
  Future<void> init(String classId, String currentMemberId) async {
    try {
      isLoading = true;
      notifyListeners();

      // まず「現在のメンバーが投票済みかどうか」を確認
      final memberDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(currentMemberId)
          .get();

      if (memberDoc.exists) {
        final data = memberDoc.data() ?? {};
        // isVotedフィールドがなければfalseになる
        isVoted = data['isVoted'] ?? false;
      } else {
        // ドキュメントが存在しなければfalse扱い
        isVoted = false;
      }

      // isVotedがtrueのときのみランキングを取得
      if (isVoted) {
        for (int i = 0; i < questionList.length; i++) {
          final docId = i.toString();

          // /classes/{classId}/rankings/{docId}/votes を取得
          final votesSnap = await FirebaseFirestore.instance
              .collection('classes')
              .doc(classId)
              .collection('rankings')
              .doc(docId)
              .collection('votes')
              .get();

          // voteDocに { count, avatarIndex, memberName } が入っている想定
          final votes = votesSnap.docs.map((voteDoc) {
            final data = voteDoc.data();
            final count = data['count'] ?? 0;
            final avatarIndex = data['avatarIndex'] ?? 0;
            final memberName = data['memberName'] ?? 'unknown';

            return RankingVote(
              memberName: memberName,
              count: count,
              avatarIndex: avatarIndex,
            );
          }).toList();

          // 票数降順にソート
          votes.sort((a, b) => b.count.compareTo(a.count));
          rankingVotes[i] = votes;
        }
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

/// ランキング表示用データクラス
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