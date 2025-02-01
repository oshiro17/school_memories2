import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/color.dart';
import 'package:school_memories2/pages/ranking_page_model.dart';

class RankingPage extends StatelessWidget {
  final String classId;
  final String currentMemberId;

  const RankingPage({
    Key? key,
    required this.classId,
    required this.currentMemberId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // RankingPageModel を取得
    return Consumer<RankingPageModel>(
      builder: (context, model, child) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE0F7FA), // very light cyan
                  Color(0xFFFFEBEE), // very light pink
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: _buildBodyContent(model),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: goldColor,
            onPressed: () {
              // forceUpdate = true => キャッシュ無視して再読み込み
              model.init(classId, currentMemberId, forceUpdate: true);
            },
            child: const Icon(Icons.refresh),
          ),
        );
      },
    );
  }

  /// メインの表示ロジック
  Widget _buildBodyContent(RankingPageModel model) {
    // 1) 全体ロード中
    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2) まだ投票していない
    if (!model.isVoted) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
          child: Text(
            'ランキングはまだ見れません\n投票してください。',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      );
    }

    // 3) 投票済みなら ListView で順次表示
    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: model.questionList.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          // 先頭にAppBarスペース
          return const SizedBox(height: kToolbarHeight + 12);
        }
        return _buildRankingCard(context, model, index - 1);
      },
    );
  }

  /// 質問ごとのランキングカード
  Widget _buildRankingCard(BuildContext context, RankingPageModel model, int index) {
    final question = model.questionList[index];
    final votes = model.rankingVotes[index]; // null=ロード中, []=投票なし, list=取得完了

    // votes が null => ロード中
    // votes が空 => 投票なし
    // votes が要素あり => 表示
    final topVotes = votes?.take(3).toList() ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 質問タイトル
            Text(
              question,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkBlueColor,
              ),
            ),
            const SizedBox(height: 16),

            if (votes == null)
              // ロード中
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (topVotes.isEmpty)
              // 投票なし
              const Text(
                'まだ投票がありません。',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              )
            else
              // 上位3名
              ...topVotes.asMap().entries.map((entry) {
                final rank = entry.key; // 0=1位,1=2位,2=3位
                final vote = entry.value;
                return ListTile(
                  // leading で、avatar の左に 王冠 と rank を表示
                  leading: SizedBox(
                    width: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // avatar
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: AssetImage('assets/j${vote.avatarIndex}.png'),
                        ),
                        // 王冠 + rank数字
                        Positioned(
                          top: -2,
                          left: -4,
                          child: _buildCrownWithRank(rank),
                        ),
                      ],
                    ),
                  ),
                  title: Text(
                    vote.memberName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // 長すぎる場合は省略
                  ),
                  trailing: Text(
                    '${vote.count}票',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  /// 王冠を表示 + rank 数字
  Widget _buildCrownWithRank(int rank) {
    // rank=0 -> 1位(金), rank=1 -> 2位(銀), rank=2 -> 3位(銅)
    late Color crownColor;
    switch (rank) {
      case 0:
        crownColor = Colors.amber;  // 金
        break;
      case 1:
        crownColor = Colors.grey;   // 銀
        break;
      case 2:
        crownColor = Colors.brown;  // 銅
        break;
      default:
        // 3位以降は表示しない
        return const SizedBox.shrink();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // 王冠アイコン
        Icon(
          Icons.emoji_events,
          color: crownColor,
          size: 35,
        ),
        // 王冠の上に順位の数字 (1, 2, 3)
        Positioned(
          top: 4,
          child: Text(
            '${rank + 1}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
