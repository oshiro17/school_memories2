import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// ダミーのクラス情報
class Class {
  final String id;
  final String name;

  Class({required this.id, required this.name});
}

/// ダミーのユーザー情報
class UserProfile {
  final String uid;
  final String name;
  final String imageURL;

  UserProfile({required this.uid, required this.name, required this.imageURL});
}

/// ダミーのランキング情報
class Ranking {
  final String name;
  final int allVotedCount;
  final Rank rank1;
  final Rank rank2;
  final Rank rank3;

  Ranking({
    required this.name,
    required this.allVotedCount,
    required this.rank1,
    required this.rank2,
    required this.rank3,
  });
}

/// ランキング内の順位情報
class Rank {
  final String uid;
  final int votedCount;

  Rank({required this.uid, required this.votedCount});
}

/// ダミーのデータプロバイダー
class RankingPageModel extends ChangeNotifier {
  final String classId;
  List<Ranking> rankingList = [];

  RankingPageModel(this.classId);

  Future<void> init(BuildContext context) async {
    // ダミーデータを設定
    rankingList = [
      Ranking(
        name: 'サンプルランキング1',
        allVotedCount: 10,
        rank1: Rank(uid: '1', votedCount: 5),
        rank2: Rank(uid: '2', votedCount: 3),
        rank3: Rank(uid: '3', votedCount: 2),
      ),
      Ranking(
        name: 'サンプルランキング2',
        allVotedCount: 7,
        rank1: Rank(uid: '4', votedCount: 4),
        rank2: Rank(uid: '5', votedCount: 2),
        rank3: Rank(uid: '6', votedCount: 1),
      ),
    ];
    notifyListeners();
  }
}

class VoteRankingPage extends StatelessWidget {
  final String classId;
  final List<Ranking>? rankingList;

  VoteRankingPage({required this.classId, required this.rankingList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  
      body: ListView.builder(
        itemCount: rankingList?.length ?? 0,
        itemBuilder: (context, index) {
          final ranking = rankingList![index];
          return ListTile(
            title: Text(ranking.name),
            subtitle: Text('総投票数: ${ranking.allVotedCount}'),
          );
        },
      ),
    );
  }
}

/// メインのランキングページ
class RankingPage extends StatelessWidget {
  final Class _class;

  RankingPage(this._class);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RankingPageModel>(
      create: (context) => RankingPageModel(_class.id)..init(context),
      child: Consumer<RankingPageModel>(
        builder: (context, model, _) {
          final rankingCardList = model.rankingList.map((ranking) {
            return _rankingCard(ranking);
          }).toList();

          return Scaffold(
    
            body: rankingCardList.isNotEmpty
                ? ListView.builder(
                    itemCount: rankingCardList.length,
                    itemBuilder: (context, index) {
                      return rankingCardList[index];
                    },
                  )
                : Center(
                    child: Text('まだランキングがないよ😇'),
                  ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.blue,
              child: Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VoteRankingPage(
                      classId: model.classId,
                      rankingList: model.rankingList,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// ランキングカード
  Widget _rankingCard(Ranking ranking) {
    return Card(
      color: Colors.blue.shade100,
      child: Column(
        children: [
          SizedBox(height: 10),
          Text(
            '${ranking.name}',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          _rankingTile(
            rank: 1,
            votedCount: ranking.rank1.votedCount,
            votedUser: UserProfile(
              uid: ranking.rank1.uid,
              name: 'ユーザー${ranking.rank1.uid}',
              imageURL: 'https://via.placeholder.com/48',
            ),
          ),
          _rankingTile(
            rank: 2,
            votedCount: ranking.rank2.votedCount,
            votedUser: UserProfile(
              uid: ranking.rank2.uid,
              name: 'ユーザー${ranking.rank2.uid}',
              imageURL: 'https://via.placeholder.com/48',
            ),
          ),
          _rankingTile(
            rank: 3,
            votedCount: ranking.rank3.votedCount,
            votedUser: UserProfile(
              uid: ranking.rank3.uid,
              name: 'ユーザー${ranking.rank3.uid}',
              imageURL: 'https://via.placeholder.com/48',
            ),
          ),
        ],
      ),
    );
  }

  /// ランキングタイル
  Widget _rankingTile({
    required int rank,
    required int votedCount,
    required UserProfile votedUser,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text('$rank位'),
          SizedBox(width: 8),
          ClipOval(
            child: Image.network(
              votedUser.imageURL,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.account_circle, size: 48, color: Colors.grey);
              },
            ),
          ),
          SizedBox(width: 8),
          Text('${votedUser.name}'),
          Spacer(),
          Text('$votedCount票'),
        ],
      ),
    );
  }
}
