import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_memories2/pages/select_people_model.dart';

class VoteRankingPageModel extends ChangeNotifier {
  bool isLoading = false;
  bool isReadyToVote = false;
  bool hasAlreadyVoted = false; 

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

  List<SelectPeopleModel> classMembers = [];
  Map<int, SelectPeopleModel?> selectedMembers = {};

  /// 初期化
  Future<void> init(String classId, String currentMemberId) async {
    try {
      isLoading = true;
      notifyListeners();

      // 1) 投票済みチェック
      final memberDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(currentMemberId)
          .get();

      final isVoted = memberDoc.data()?['isVoted'] ?? false;
      if (isVoted) {
        hasAlreadyVoted = true;
        return;
      }

      // 2) 未投票の場合 -> 質問数だけ null で初期化
      for (int i = 0; i < questionList.length; i++) {
        selectedMembers[i] = null;
      }

      // 3) メンバー一覧を取得 (doc.data() は as Map でキャスト)
      final membersSnap = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .get();

      classMembers = membersSnap.docs.map((doc) {
        // doc.data() => Object? なので、必ず as Map<String,dynamic> キャスト
        final map = doc.data() as Map<String, dynamic>;
        return SelectPeopleModel.fromMap(map);
      }).toList();

      _updateVoteReadiness();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// メンバー選択
  void setSelectedMember(int questionIndex, SelectPeopleModel? member) {
    selectedMembers[questionIndex] = member;
    _updateVoteReadiness();
  }

  /// 全質問回答済みかどうか
  void _updateVoteReadiness() {
    isReadyToVote = selectedMembers.values.every((m) => m != null);
    notifyListeners();
  }

  /// 投票ボタン押下時
  Future<void> submitVotes(String classId, String currentMemberId) async {
    if (!isReadyToVote) {
      throw 'すべての質問に投票してください。';
    }

    try {
      isLoading = true;
      notifyListeners();

      final batch = FirebaseFirestore.instance.batch();

      // (1) 各設問 => 選択メンバーに票を加算
      for (final entry in selectedMembers.entries) {
        final questionIndex = entry.key;
        final member = entry.value;
        if (member == null) continue;

        final docId = questionIndex.toString(); // "0","1" など
        final rankingDocRef = FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .collection('rankings')
            .doc(docId);

        final voteDocRef = rankingDocRef
            .collection('votes')
            .doc(member.id); // memberID をドキュメントIDに

        // **ここがポイント**: メンバー名を保存
        batch.set(
                  voteDocRef,
                  {
                    'count': FieldValue.increment(1),
                    'memberId': member.id,
                    
                    // 'avatarIndex': member.avatarIndex,
                    // 'memberName': member.name, // これを Firestore に保存
                  },
                  SetOptions(merge: true),
                );
      }

      // (2) 自分の isVoted を true に
      final selfRef = FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(currentMemberId);
      batch.update(selfRef, {'isVoted': true});

      // (3) 一括コミット
      await batch.commit();

      hasAlreadyVoted = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}