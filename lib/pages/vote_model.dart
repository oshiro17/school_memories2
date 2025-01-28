// vote_ranking_page_model.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_memories2/pages/message.dart';
import 'package:school_memories2/pages/select_people_model.dart';
import '../class_model.dart'; // SelectPeopleModel など

class VoteRankingPageModel extends ChangeNotifier {
  final List<String> sampleRankings = [
    'サンプルランキング1',
    'サンプルランキング2',
  ];

  bool isLoading = false;
  bool isReadyToVote = false; // 投票ボタンの有効/無効を管理
  bool hasAlreadyVoted = false; // すべて投票済みなら true

  // クラスのメンバー一覧
  List<SelectPeopleModel> classMembers = [];
  // 各ランキングで選ばれたメンバー
  Map<String, SelectPeopleModel?> selectedMembers = {};

  Future<void> init(String classId) async {
    try {
      isLoading = true;
      notifyListeners();

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw 'ログイン情報がありません';

      // Firestore から既に投票済みのランキングを確認
      final userVotesSnap = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('rankings')
          .where('votesDone.$userId', isEqualTo: true)
          .get();
      final alreadyVotedRankings = userVotesSnap.docs.map((doc) => doc.id).toSet();

      // 投票済みならフラグを立てる
      if (alreadyVotedRankings.length == sampleRankings.length) {
        hasAlreadyVoted = true;
        return;
      }

      // 投票可能なランキングをフィルタリング
      for (final ranking in sampleRankings) {
        if (!alreadyVotedRankings.contains(ranking)) {
          selectedMembers[ranking] = null;
        }
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
  Future<void> submitVotes(String classId) async {
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

        // 投票履歴を記録
        batch.set(
          votesRef,
          {'votesDone.$userId': true},
          SetOptions(merge: true),
        );
      }

      await batch.commit();
      hasAlreadyVoted = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
