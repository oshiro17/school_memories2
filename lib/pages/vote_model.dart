import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_memories2/pages/select_people_model.dart';
// 投票先メンバーを選択するモデル (SelectPeopleModel)などもインポート
// 例）import 'select_people_model.dart';

class VoteRankingPageModel extends ChangeNotifier {
  bool isLoading = false;
  bool isReadyToVote = false;   // 投票ボタンの有効/無効
  bool hasAlreadyVoted = false; // すでに投票済みなら true

  // コード中だけで持つランキング設問の一覧 (Firestoreには保存しない)
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
    // ...以下同様

  // クラスのメンバー一覧
  List<SelectPeopleModel> classMembers = [];

  // 選択されたメンバー: 質問のインデックス => 選んだメンバー
  // (例) selectedMembers[0] => questionList[0]の投票先
  Map<int, SelectPeopleModel?> selectedMembers = {};

  Future<void> init(String classId, String currentMemberId) async {
    try {
      isLoading = true;
      notifyListeners();

      // すでに投票済みかどうか判定 (クラス内のmembers/{currentMemberId}.isVoted など)
      final memberDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(currentMemberId)
          .get();
      final isVoted = memberDoc.data()?['isVoted'] ?? false;
      if (isVoted) {
        hasAlreadyVoted = true;
        return; // 投票済みならそれを通知して終了
      }

      // 全質問(0..questionList.length-1)について、まだ選択してないので null で初期化
      for (int i = 0; i < questionList.length; i++) {
        selectedMembers[i] = null;
      }

      // メンバー一覧を取得
      final membersSnap = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .get();
      classMembers = membersSnap.docs.map((doc) {
        return SelectPeopleModel.fromMap(doc.data());
      }).toList();

      // 投票ボタンの有効/無効を判定
      _updateVoteReadiness();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ドロップダウンでメンバーを選択したとき
  void setSelectedMember(int questionIndex, SelectPeopleModel? member) {
    selectedMembers[questionIndex] = member;
    _updateVoteReadiness();
  }

  // 全質問に対してメンバーが選ばれているかどうかを判定
  void _updateVoteReadiness() {
    isReadyToVote = selectedMembers.values.every((member) => member != null);
    notifyListeners();
  }

  // 投票を実行
  Future<void> submitVotes(String classId, String currentMemberId) async {
    if (!isReadyToVote) {
      throw 'すべての質問に投票してください。';
    }

    try {
      isLoading = true;
      notifyListeners();

      final batch = FirebaseFirestore.instance.batch();

      // 各設問(= questionIndex)について選択されたメンバーに票を入れる
      selectedMembers.forEach((questionIndex, member) {
        final docId = questionIndex.toString();  // "0", "1" のように文字列化
        final rankingDocRef = FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .collection('rankings')
            .doc(docId);

        // votesサブコレクション下の {member.id} ドキュメントをインクリメント
        final voteDocRef = rankingDocRef.collection('votes').doc(member!.id);
        batch.set(
          voteDocRef,
          {
            'count': FieldValue.increment(1),
          },
          SetOptions(merge: true),
        );
      });

      // 投票したメンバー自身に「投票済み」を記録
      final selfRef = FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(currentMemberId);
      batch.update(selfRef, {'isVoted': true});

      // 一括実行
      await batch.commit();

      hasAlreadyVoted = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
