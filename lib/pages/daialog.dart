import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/class_model.dart';
import 'package:school_memories2/pages/write_message.dart';
import 'select_people.dart';
import 'vote.dart';

class MainMemoriesDialog extends StatelessWidget {
    final ClassModel classInfo;
  final String currentMemberId;
      const MainMemoriesDialog({required this.classInfo, Key? key, required this.currentMemberId,}) : super(key: key);
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
                builder: (context) => WriteMessagePage(classInfo: classInfo, currentMemberId: currentMemberId),
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
                  classId: classInfo.id,
     // ダミーデータ
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
