import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/class_model.dart';
import 'package:school_memories2/pages/write_message.dart';
import 'select_people.dart';
import 'vote.dart';

class MainMemoriesDialog extends StatelessWidget {
    final ClassModel classInfo;
      const MainMemoriesDialog({required this.classInfo, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('メニュー'),
      children: [
        SimpleDialogOption(
          child: Text('寄せ書きを書く'),
          onPressed: () {
           Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WriteMessagePage(classInfo: classInfo),
              ),
            ); 
            // Navigator.pop(context); // ダイアログを閉じる
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => ClassMemberPage(action: ClassMemberAction.writeMessage, classInfo: classInfo),
            //   ),
            // );
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
