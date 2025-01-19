import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'select_people.dart';

class VoteRankingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ランキングに投票： ClassMemberPage(action=voteRanking) へ
    return Scaffold(
      appBar: AppBar(title: Text('VoteRankingPage')),
      body: Center(
        child: ElevatedButton(
          child: Text('ランキングを選んで投票'),
          onPressed: () async {
            final result = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                builder: (context) => ClassMemberPage(action: ClassMemberAction.voteRanking),
              ),
            );
            // resultに投票相手の名前が入ってくる想定
            if (result != null && result.isNotEmpty) {
              // 投票完了処理など
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$result に投票しました！')),
              );
            }
          },
        ),
      ),
    );
  }
}