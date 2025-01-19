import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'vote.dart';

class RankingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 右下ボタンで VoteRankingPage へ遷移
    return Scaffold(
      body: Center(
        child: Text('RankingPage'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.how_to_vote),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VoteRankingPage()),
          );
        },
      ),
    );
  }
}