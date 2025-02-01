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
    return Consumer<RankingPageModel>(
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
            child: _buildBodyContent(model),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // キャッシュを無視してFirestoreからデータを再取得
              model.init(classId, currentMemberId, forceUpdate: true);
            },
            child: const Icon(Icons.refresh),
            backgroundColor: goldColor,
          ),
        );
      },
    );
  }

  /// コンテンツの表示ロジック
  Widget _buildBodyContent(RankingPageModel model) {
    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!model.isVoted) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
          child: Text(
            'ランキングはまだ見れません。\n投票してください。',
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

    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: model.questionList.length + 1, // SizedBox分のアイテムを追加
      itemBuilder: (context, index) {
        if (index == 0) {
          // AppBarの高さ分のスペースを確保
          return const SizedBox(height: kToolbarHeight + 12); 
        }
        return _buildRankingCard(context, model, index - 1);
      },
    );
  }

  /// ランキングカードの生成
  Widget _buildRankingCard(BuildContext context, RankingPageModel model, int index) {
    final question = model.questionList[index];
    final votes = model.rankingVotes[index] ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            const SizedBox(height: 12),
            if (votes.isEmpty)
              const Text(
                'まだ投票がありません。',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              )
            else
              ...votes.map((vote) => ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage('assets/j${vote.avatarIndex}.png'),
                    ),
                    title: Text(vote.memberName),
                    trailing: Text('${vote.count}票'),
                  )),
          ],
        ),
      ),
    );
  }
}
