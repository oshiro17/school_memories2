import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RankingPageModel extends ChangeNotifier {
  bool isLoading = false;    // 全体の読み込みフラグ
  bool isVoted = false;      // 現在ユーザーが投票済みかどうか

  /// 質問一覧
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

  /// 質問ごとのランキングデータ  
  /// - key: 質問のインデックス  
  /// - value: まだ読み込んでいない(= null) or 取得完了したランキングリスト
  Map<int, List<RankingVote>?> rankingVotes = {};

  /// Firestore から投票状況 & ランキングを取得 (質問単位で逐次ロード)
  Future<void> init(
    String classId,
    String currentMemberId, {
    bool forceUpdate = false,
  }) async {
    isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'ranking_${classId}_$currentMemberId';

    // 1) キャッシュがあれば読む（強制更新でない場合）
    if (!forceUpdate) {
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        try {
          final cachedJson = jsonDecode(cachedData);
          _loadFromCache(cachedJson);
          // いったん読み込みフラグをfalseにして、画面にキャッシュを表示
          isLoading = false;
          notifyListeners();
        } catch (e) {
          print('キャッシュの読み込みに失敗: $e');
        }
      }
    }

    // 2) Firestore から「投票済みかどうか」を確認
    try {
      final memberDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(currentMemberId)
          .get();
      if (memberDoc.exists) {
        final data = memberDoc.data() ?? {};
        isVoted = data['isVoted'] ?? false;
      } else {
        isVoted = false;
      }
    } catch (e) {
      print('投票状態チェック失敗: $e');
    }

    // 投票していないなら、ここで終了
    if (!isVoted) {
      isLoading = false;
      notifyListeners();
      return;
    }

    // 3) 投票済みなら順次ランキングをロード
    isLoading = false; 
    notifyListeners(); // 画面を部分的に表示可能に

    // 質問数だけループし、各質問の投票情報を取得
    for (int i = 0; i < questionList.length; i++) {
      // まだロードしていない項目は null をセット（キャッシュがなければ）
      rankingVotes.putIfAbsent(i, () => null);

      // Firestore: rankings/i/votes コレクションを取得
      try {
        final docId = i.toString();
        final votesSnap = await FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .collection('rankings')
            .doc(docId)
            .collection('votes')
            .get();

        // 投票ドキュメント一覧 => memberId => membersサブコレクションから最新の name, avatarIndex を取得
        final votes = await Future.wait(votesSnap.docs.map((voteDoc) async {
          final data = voteDoc.data();
          final memberId = data['memberId'] as String?;
          final count = data['count'] ?? 0;

          if (memberId == null) {
            // もし memberId がなければ unknown
            return RankingVote(
              memberName: 'unknown',
              avatarIndex: 0,
              count: count,
            );
          }

          // 最新のメンバー情報を参照
          final memberRef = FirebaseFirestore.instance
              .collection('classes')
              .doc(classId)
              .collection('members')
              .doc(memberId);

          final memberSnap = await memberRef.get();
          if (!memberSnap.exists) {
            // もし該当ユーザーが見つからなければ
            return RankingVote(
              memberName: 'unknown',
              avatarIndex: 0,
              count: count,
            );
          }

          final memberData = memberSnap.data() as Map<String, dynamic>?;

          // 最新の avatarIndex, name を取得
          final avatarIndex = memberData?['avatarIndex'] ?? 0;
          final memberName = memberData?['name'] ?? 'unknown';

          return RankingVote(
            memberName: memberName,
            avatarIndex: avatarIndex,
            count: count,
          );
        }).toList());

        // 投票数の多い順にソート
        votes.sort((a, b) => b.count.compareTo(a.count));

        // 読み込み完了
        rankingVotes[i] = votes;
        notifyListeners();

      } catch (e) {
        print('質問$i ロード失敗: $e');
        // エラーなら空リスト
        rankingVotes[i] = [];
        notifyListeners();
      }
    }

    // 4) 全部ロード後、キャッシュに保存
    await prefs.setString(cacheKey, jsonEncode(_toCacheJson()));
  }

  /// キャッシュから復元
  void _loadFromCache(Map<String, dynamic> cachedJson) {
    isVoted = cachedJson['isVoted'] ?? false;
    if (!isVoted) return;

    final cachedMap = cachedJson['rankingVotes'] as Map<String, dynamic>;
    rankingVotes = cachedMap.map((key, value) {
      final index = int.parse(key);
      final list = (value as List).map((e) => RankingVote.fromJson(e)).toList();
      return MapEntry(index, list);
    });
  }

  /// キャッシュ用にJSON化
  Map<String, dynamic> _toCacheJson() {
    return {
      'isVoted': isVoted,
      'rankingVotes': rankingVotes.map((key, value) {
        final list = value ?? [];
        return MapEntry(key.toString(), list.map((v) => v.toJson()).toList());
      }),
    };
  }
}

/// ランキング用データ
class RankingVote {
  final String memberName;
  final int avatarIndex;
  final int count;

  RankingVote({
    required this.memberName,
    required this.avatarIndex,
    required this.count,
  });

  factory RankingVote.fromJson(Map<String, dynamic> json) {
    return RankingVote(
      memberName: json['memberName'],
      avatarIndex: json['avatarIndex'],
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memberName': memberName,
      'avatarIndex': avatarIndex,
      'count': count,
    };
  }
}
