//ranking_page_model.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RankingPageModel extends ChangeNotifier {
  bool isLoading = false;    // 全体の読み込みフラグ
  bool isVoted = false;      // 現在ユーザーが投票済みかどうか
  String? errorMessage;      // エラー状態を保持するフィールド

  /// 質問一覧
  final List<String> questionList = [
    'モテるのは？',
    'おしゃべりなのは？',
    '頭がいいのは？',
    'お笑い芸人になりそうなのは？',
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
    'ワイルドなのは？',
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
    errorMessage = null; // 初期化時にエラー状態をリセット
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
          isLoading = false;
          notifyListeners();
        } catch (e) {
          print('キャッシュの読み込みに失敗: $e');
          errorMessage = 'キャッシュの読み込みに失敗しました: $e';
          notifyListeners();
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

        print("ここきた");
      } else {
        isVoted = false;
      }
    } catch (e) {
      print('投票状態チェック失敗: $e');
      errorMessage = '投票状態のチェックに失敗しました: $e';
      notifyListeners();
    }

    // 投票していないなら、ここで終了
    if (!isVoted) {
      isLoading = false;
      notifyListeners();
      return;
    }

    // 3) 投票済みなら順次ランキングをロード
    isLoading = false; 
  
    notifyListeners(); // 画面更新可能に

    for (int i = 0; i < questionList.length; i++) {
      // キャッシュがなければ null をセット
      rankingVotes.putIfAbsent(i, () => null);

      try {
        final docId = i.toString();
        final votesSnap = await FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .collection('rankings')
            .doc(docId)
            .collection('votes')
            .get();

        // 投票ドキュメント一覧から、各メンバーの最新情報を取得
        final votes = await Future.wait(votesSnap.docs.map((voteDoc) async {
          final data = voteDoc.data();
          final memberId = data['memberId'] as String?;
          final count = data['count'] ?? 0;

          if (memberId == null) {
            return RankingVote(
              memberName: 'unknown',
              avatarIndex: 0,
              count: count,
            );
          }

          final memberRef = FirebaseFirestore.instance
              .collection('classes')
              .doc(classId)
              .collection('members')
              .doc(memberId);

          final memberSnap = await memberRef.get();
          if (!memberSnap.exists) {
            return RankingVote(
              memberName: 'unknown',
              avatarIndex: 0,
              count: count,
            );
          }

          final memberData = memberSnap.data() as Map<String, dynamic>?;
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

        rankingVotes[i] = votes;
        notifyListeners();
      } catch (e) {
        print('質問$i ロード失敗: $e');
        rankingVotes[i] = [];
        errorMessage = '質問$i のロードに失敗しました: $e';
        notifyListeners();
      }
    }

    // 4) 全部ロード後、キャッシュに保存
    try {
      await prefs.setString(cacheKey, jsonEncode(_toCacheJson()));
    } catch (e) {
      print('キャッシュ保存に失敗しました: $e');
      errorMessage = 'キャッシュ保存に失敗しました: $e';
      notifyListeners();
    }
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
