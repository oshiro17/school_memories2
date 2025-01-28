// vote_ranking_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/class_model.dart';
import 'package:school_memories2/pages/message.dart';
import 'package:school_memories2/pages/select_people_model.dart';
import 'vote_model.dart';

class VoteRankingPage extends StatelessWidget {
  final String classId;

  const VoteRankingPage({
    Key? key,
    required this.classId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VoteRankingPageModel>(
      create: (_) => VoteRankingPageModel()..init(classId),
      child: Consumer<VoteRankingPageModel>(
        builder: (context, model, child) {
          if (model.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

         if (model.hasAlreadyVoted) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('投票済み'),
    ),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'すでに投票済みです！',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // 前の画面に戻る
            },
            child: const Text("戻る"),
          ),
        ],
      ),
    ),
  );
}

          return Scaffold(
            appBar: AppBar(
              title: const Text('ランキングに投票する'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  for (final rankingName in model.sampleRankings) ...[
                    _buildRankingDropdown(model, rankingName),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 20),
                 ElevatedButton(
  onPressed: model.isReadyToVote
      ? () async {
          try {
            await model.submitVotes(classId); // 投票処理を実行

            // 投票完了のメッセージを表示
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('投票が完了しました！'),
              ),
            );

            // メッセージが表示された後に前の画面に戻る
            Future.delayed(const Duration(seconds: 1), () {
              // Navigator.pop(context); // 前の画面に戻る
            });
          } catch (e) {
            // エラーハンドリング
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('エラー'),
                content: Text(e.toString()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('閉じる'),
                  ),
                ],
              ),
            );
          }
        }
      : null, // 投票準備が整っていない場合はボタン無効
  child: const Text('投票する'),
),

                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRankingDropdown(VoteRankingPageModel model, String rankingName) {
    final selectedMember = model.selectedMembers[rankingName];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rankingName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        DropdownButton<SelectPeopleModel>(
          value: selectedMember,
          hint: const Text('投票先を選択'),
          items: model.classMembers.map((member) {
            return DropdownMenuItem<SelectPeopleModel>(
              value: member,
              child: Text(member.name),
            );
          }).toList(),
          onChanged: (newValue) {
            model.setSelectedMember(rankingName, newValue);
          },
        ),
      ],
    );
  }
}
