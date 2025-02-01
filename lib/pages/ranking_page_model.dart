import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RankingPageModel extends ChangeNotifier {
  bool isLoading = false;
  bool isVoted = false;

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

  Map<int, List<RankingVote>> rankingVotes = {};

  /// FirestoreからisVoted判定 & ランキング情報取得
  Future<void> init(String classId, String currentMemberId, {bool forceUpdate = false}) async {
    isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'ranking_${classId}_$currentMemberId';

    // キャッシュが存在する場合はそれを使用（強制更新でない場合）
    if (!forceUpdate) {
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        try {
          final cachedJson = json.decode(cachedData);
          _loadFromCache(cachedJson);
          isLoading = false;
          notifyListeners();
          return;
        } catch (e) {
          print('キャッシュの読み込みに失敗しました: $e');
        }
      }
    }

    // Firestoreからデータ取得
    try {
      // まず「現在のメンバーが投票済みかどうか」を確認
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

      // isVotedがtrueのときのみランキングを取得
      if (isVoted) {
        for (int i = 0; i < questionList.length; i++) {
          final docId = i.toString();
          final votesSnap = await FirebaseFirestore.instance
              .collection('classes')
              .doc(classId)
              .collection('rankings')
              .doc(docId)
              .collection('votes')
              .get();

          final votes = votesSnap.docs.map((voteDoc) {
            final data = voteDoc.data();
             final votesMembersSnap = await FirebaseFirestore.instance
              .collection('classes')
              .doc(classId)
              .collection('users')
              .doc( data['memberId'])
              // .collection('members')
              .get();
            return RankingVote(
              // memberName: data['memberName'] ?? 'unknown',
              count: data['count'] ?? 0,
              // avatarIndex: data['avatarIndex'] ?? 0,
            );
          }).toList();

          votes.sort((a, b) => b.count.compareTo(a.count));
          rankingVotes[i] = votes;
        }

        // キャッシュを更新
        await prefs.setString(cacheKey, json.encode(_toCacheJson()));
      }
    } catch (e) {
      print('Firestoreからのデータ取得中にエラーが発生しました: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// キャッシュからデータをロード
  void _loadFromCache(Map<String, dynamic> cachedJson) {
    isVoted = cachedJson['isVoted'] ?? false;

    if (isVoted) {
      final cachedVotes = cachedJson['rankingVotes'] as Map<String, dynamic>;
      rankingVotes = cachedVotes.map((key, value) {
        final index = int.parse(key);
        final votesList = (value as List).map((e) => RankingVote.fromJson(e)).toList();
        return MapEntry(index, votesList);
      });
    }
  }

  /// キャッシュ用にJSONに変換
  Map<String, dynamic> _toCacheJson() {
    return {
      'isVoted': isVoted,
      'rankingVotes': rankingVotes.map((key, value) {
        return MapEntry(key.toString(), value.map((vote) => vote.toJson()).toList());
      }),
    };
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

  /// JSONからのデータ復元
  factory RankingVote.fromJson(Map<String, dynamic> json) {
    return RankingVote(
      memberName: json['memberName'],
      count: json['count'],
      avatarIndex: json['avatarIndex'],
    );
  }

  /// JSONへの変換
  Map<String, dynamic> toJson() {
    return {
      'memberName': memberName,
      'count': count,
      'avatarIndex': avatarIndex,
    };
  }
}
