import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_memories2/pages/select_people_model.dart';

class VoteRankingPageModel extends ChangeNotifier {
  bool isLoading = false;
  bool isReadyToVote = false;
  bool hasAlreadyVoted = false; 

  final List<String> questionList = [
    'モテるのは？',
  'おしゃべりなのは？',
  '頭がいいのは？',
  '妄想が激しいのは？',
  '結婚が早そうなのは？',
  'お金持ちになりそうなのは？',
  '海外に住みそうなのは？',
  '有名になりそうなのは？',
  '会社の社長になりそうなのは？',
  '世界一周しそうなのは？',
  '力持ちなのは？',
  '忘れ物が多いのは？',
  '優しいのは？',
  'イケメンなのは？',
  '可愛いのは？',
  '天然なのは？',
  'うるさいのは？',
  '世界を救いそうなのは？',
  'オリンピックに出てそうなのは？',
  'お母さんにしたいのは？',
  'お父さんにしたいのは？',
  '妹にしたいのは？',
  '姉にしたいのは？',
  '弟にしたいのは？',
  '兄にしたいのは？',
  '奥さんにしたいのは？',
  '旦那さんにしたいのは？',
  '「王子様」っぽいのは？',
  '「お姫様」っぽいのは？',
  'アイドルになりそうなのは？',
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

    for (final entry in selectedMembers.entries) {
      final questionIndex = entry.key;
      final member = entry.value;
      if (member == null) continue;

      final docId = questionIndex.toString();
      final rankingDocRef = FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('rankings')
          .doc(docId);

      final voteDocRef = rankingDocRef.collection('votes').doc(member.id);

      batch.set(
        voteDocRef,
        {
          'count': FieldValue.increment(1),
          'memberId': member.id,
        },
        SetOptions(merge: true),
      );
    }

    final selfRef = FirebaseFirestore.instance
        .collection('classes')
        .doc(classId)
        .collection('members')
        .doc(currentMemberId);
    batch.update(selfRef, {'isVoted': true});

    await batch.commit();

    hasAlreadyVoted = true;
  } on FirebaseException catch (e) {
    if (e.code == 'unavailable') {

    } else {
      throw 'Firebaseエラー: ${e.message}';
    }
  } catch (e) {
    throw 'エラー: $e';
  } finally {
    isLoading = false;
    notifyListeners();
  }
}

}