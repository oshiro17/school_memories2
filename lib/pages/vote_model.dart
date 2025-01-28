// vote_ranking_page_model.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_memories2/pages/select_people_model.dart';

class VoteRankingPageModel extends ChangeNotifier {
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

  bool isLoading = false;
  bool isReadyToVote = false; // 投票ボタンの有効/無効を管理
  bool hasAlreadyVoted = false; // すべて投票済みなら true

  // クラスのメンバー一覧
  List<SelectPeopleModel> classMembers = [];
  // 各ランキングで選ばれたメンバー
  Map<String, SelectPeopleModel?> selectedMembers = {};

  Future<void> init(String classId, String currentMemberId )async {
    try {
      isLoading = true;
      notifyListeners();

      
      // // Firestore から既に投票済みのランキングを確認
      final userVotesSnap = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(currentMemberId)
          .get();
        
      final isVoted = userVotesSnap.data()?['isVoted'] ?? false;
      if (isVoted) {
        hasAlreadyVoted = true;
        return;
      }

      for (final ranking in sampleRankings) {
          selectedMembers[ranking] = null;
      }

      // クラスメンバーを取得
      final membersSnap = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .get();
      classMembers = membersSnap.docs.map((doc) {
        final data = doc.data();
        return SelectPeopleModel.fromMap(data);
      }).toList();

      // 投票可能かどうかをチェック
      _updateVoteReadiness();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ドロップダウン選択時に呼び出す
  void setSelectedMember(String rankingName, SelectPeopleModel? member) {
    selectedMembers[rankingName] = member;
    _updateVoteReadiness();
  }

  // 全ランキングで選択済みかどうかを確認
  void _updateVoteReadiness() {
    isReadyToVote = selectedMembers.values.every((value) => value != null);
    notifyListeners();
  }

  // 投票処理
  Future<void> submitVotes(String classId,String currentMemberId) async {
    if (!isReadyToVote) throw 'すべてのランキングに投票してください';

    try {
      isLoading = true;
      notifyListeners();

      final batch = FirebaseFirestore.instance.batch();
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // 各ランキングで投票を記録
      for (final entry in selectedMembers.entries) {
        final rankingName = entry.key;
        final selectedMember = entry.value!;
        final votesRef = FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .collection('rankings')
            .doc(rankingName);

        // 投票数をインクリメント
        final voteRef = votesRef.collection('votes').doc(selectedMember.id);
        batch.set(
          voteRef,
          {'count': FieldValue.increment(1)},
          SetOptions(merge: true),
        );
          
          final Votes = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(currentMemberId)
          .update({'isVoted': true});
  


      }

      await batch.commit();
      hasAlreadyVoted = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
