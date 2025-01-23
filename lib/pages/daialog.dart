import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'select_people.dart';
import 'vote.dart';

class MainMemoriesDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('メニュー'),
      children: [
        SimpleDialogOption(
          child: Text('寄せ書きを書く'),
          onPressed: () {
            Navigator.pop(context); // ダイアログを閉じる
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClassMemberPage(action: ClassMemberAction.writeMessage),
              ),
            );
          },
        ),
        SimpleDialogOption(
          child: Text('ランキングを投票する'),
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VoteRankingPage(
                  classId: 'dummyClassId', // ダミーのclassIdを渡す
                  rankingList: ['サンプルランキング1', 'サンプルランキング2'], // ダミーデータ
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
