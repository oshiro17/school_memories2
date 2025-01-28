import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/pages/ranking_page_model.dart';

class RankingPage extends StatelessWidget {
  final String classId;

  const RankingPage({Key? key, required this.classId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RankingPageModel>(
      create: (_) => RankingPageModel()..init(classId),
      child: Consumer<RankingPageModel>(
        builder: (context, model, child) {
          if (model.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            appBar: AppBar(title: const Text('ランキング結果')),
            body: ListView.builder(
              itemCount: model.questionList.length,
              itemBuilder: (context, i) {
                return _buildRankingCard(model, i);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRankingCard(RankingPageModel model, int index) {
    final title = model.questionList[index];
    final votesData = model.rankingVotes[index] ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: votesData.isEmpty
            ? Text('$title\nまだ投票がありません')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  for (int rank = 0; rank < votesData.length; rank++) ...[
                    Text(
                      '${rank + 1}位: ${votesData[rank].memberName}  ${votesData[rank].count}票',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
