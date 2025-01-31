import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/pages/ranking_page_model.dart';

/// ランキングページ
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
    return ChangeNotifierProvider<RankingPageModel>(
      // RankingPageModelに currentMemberId を渡すようにして、初期化メソッド内でも使えるようにする
      create: (_) => RankingPageModel()..init(classId, currentMemberId),
      child: Consumer<RankingPageModel>(
        builder: (context, model, child) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE0F7FA), // very light cyan
                    Color(0xFFFFEBEE), // クリーム色
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              // isLoadingまたはisVotedによって表示内容を分岐
              child: () {
                if (model.isLoading) {
                  // ローディング時にも背景グラデーションが見えるようにしつつ、中央にインジケータを配置
                  return const Center(child: CircularProgressIndicator());
                }
                // 読み込み完了後、isVoted == false ならランキングを見せない
                if (!model.isVoted) {
                  return Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 57, left: 7, right: 7),
                    child: Text(
                       'ランキングはまだ見れません\n投票してください。',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                      
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
                }

                // isVoted == true の場合はランキングを表示
                return ListView.builder(
                  itemCount: model.questionList.length,
                  itemBuilder: (context, i) {
                    return _buildRankingCard(context, model, i);
                  },
                );
              }(),
            ),
          );
        },
      ),
    );
  }

  /// ランキング表示用カードウィジェット
  Widget _buildRankingCard(BuildContext context, RankingPageModel model, int index) {
    final title = model.questionList[index];
    final votesData = model.rankingVotes[index] ?? [];

    // 上位3人のみ表示
    final top3 = votesData.take(3).toList();

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: top3.isEmpty
            ? Text(
                '$title\nまだ投票がありません',
                style: const TextStyle(fontSize: 16),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ランキングタイトル
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // 上位3人表示
                  for (int rank = 0; rank < top3.length; rank++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          // 順位アイコン
                          _buildRankIcon(rank),
                          const SizedBox(width: 8),
                          // アバター画像 (丸く表示)
                          ClipOval(
                            child: Image.asset(
                              'assets/j${top3[rank].avatarIndex}.png',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          // 名前 + 票数
                          Expanded(
                            child: Text(
                              '${top3[rank].memberName}  ${top3[rank].count}票',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  /// 順位アイコン
  Widget _buildRankIcon(int rank) {
    switch (rank) {
      case 0:
        return const Icon(Icons.looks_one, color: Colors.amber, size: 28);
      case 1:
        return const Icon(Icons.looks_two, color: Colors.grey, size: 28);
      case 2:
        return const Icon(Icons.looks_3, color: Colors.brown, size: 28);
      default:
        return Text('${rank + 1}位');
    }
  }
}
