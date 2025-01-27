// ranking_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ranking_page_model.dart';

class RankingPage extends StatelessWidget {
  final String classId;

  const RankingPage({
    Key? key,
    required this.classId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RankingPageModel>(
      create: (_) => RankingPageModel()..init(classId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ランキング結果'),
        ),
        body: Consumer<RankingPageModel>(
          builder: (context, model, child) {
            if (model.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              children: [
                for (final rankingName in model.sampleRankings) ...[
                  _buildRankingCard(model, rankingName),
                  const SizedBox(height: 16),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRankingCard(RankingPageModel model, String rankingName) {
    final votesData = model.rankingVotes[rankingName] ?? [];

    if (votesData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '$rankingName\nまだ投票がありません',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    } else {
      // 票数の多い順に並んでいると仮定
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rankingName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // 上位順に表示 (1位, 2位, 3位...)
              for (int i = 0; i < votesData.length; i++) ...[
                Text(
                  '${i + 1}位: ${votesData[i].memberName}  ${votesData[i].count}票',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ],
          ),
        ),
      );
    }
  }
}
