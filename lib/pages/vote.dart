import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/class_model.dart';
import 'package:school_memories2/pages/select_people_model.dart';
import 'package:school_memories2/pages/vote_model.dart';

class VoteRankingPage extends StatelessWidget {
  final String classId;
  final String currentMemberId;

  const VoteRankingPage({
    Key? key,
    required this.classId,
    required this.currentMemberId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // FutureBuilder を利用して初回の接続状態を取得（初期値はオンラインと仮定）
    return FutureBuilder<ConnectivityResult>(
     future: Connectivity().checkConnectivity().then((results) => results.first),

      initialData: ConnectivityResult.mobile,
      builder: (context, snapshot) {
        final initialConnectivity = snapshot.data ?? ConnectivityResult.mobile;
        // その後、ストリームで最新の接続状態に更新
        return StreamBuilder<ConnectivityResult>(
          initialData: initialConnectivity,
         stream: Connectivity().onConnectivityChanged.map(
  (results) => results.isNotEmpty ? results.first : ConnectivityResult.none,
),

          builder: (context, snapshot) {
            final connectivityResult = snapshot.data ?? ConnectivityResult.mobile;
            final offline = connectivityResult == ConnectivityResult.none;

            return ChangeNotifierProvider<VoteRankingPageModel>(
              create: (_) => VoteRankingPageModel()..init(classId, currentMemberId),
              child: Consumer<VoteRankingPageModel>(
                builder: (context, model, child) {
                  if (model.isLoading) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (model.hasAlreadyVoted) {
                    return Scaffold(
                      appBar: AppBar(title: const Text('投票済み')),
                      body: const Center(child: Text('すでに投票済みです！')),
                    );
                  }
                  return Scaffold(
                    appBar: AppBar(title: const Text('ランキングに投票する')),
                    body: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          for (int i = 0; i < model.questionList.length; i++) ...[
                            _buildRankingDropdown(context, model, i),
                            const SizedBox(height: 16),
                          ],
                          ElevatedButton(
                            // オフラインの場合は onPressed を null にしてボタンを無効化
                            onPressed: (model.isReadyToVote && !offline)
                                ? () => _onSubmit(context, model)
                                : null,
                            child: const Text('投票する'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRankingDropdown(
    BuildContext context,
    VoteRankingPageModel model,
    int questionIndex,
  ) {
    final questionText = model.questionList[questionIndex];
    final selectedMember = model.selectedMembers[questionIndex];

    return Column(
      children: [
        Text(
          questionText,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            model.setSelectedMember(questionIndex, newValue);
          },
        ),
      ],
    );
  }

  Future<void> _onSubmit(BuildContext context, VoteRankingPageModel model) async {
    try {
      await model.submitVotes(classId, currentMemberId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('投票が完了しました！')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラー: $e')),
      );
    }
  }
}
