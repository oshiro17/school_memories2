import 'package:flutter/material.dart';
import 'package:school_memories2/class_model.dart';
import 'package:school_memories2/pages/change_password_dialog.dart';
import 'package:school_memories2/pages/write_message.dart';
import 'package:school_memories2/pages/vote.dart';
import 'package:school_memories2/signup/class_selection_page.dart';
import 'package:school_memories2/signup/select_account_page.dart';

class MainMemoriesDialog extends StatelessWidget {
  final ClassModel classInfo;
  final String currentMemberId;

  const MainMemoriesDialog({
    required this.classInfo,
    required this.currentMemberId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('メニュー'),
      children: [
        SimpleDialogOption(
          child: const Text('寄せ書きを書く'),
          onPressed: () {
            Navigator.pop(context); // ダイアログを閉じる
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WriteMessagePage(
                  classId: classInfo.id,
                  currentMemberId: currentMemberId,
                ),
              ),
            );
          },
        ),
        SimpleDialogOption(
          child: const Text('ランキングを投票する'),
          onPressed: () {
            Navigator.pop(context); 
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VoteRankingPage(
                  classId: classInfo.id,
                  currentMemberId: currentMemberId,
                ),
              ),
            );
          },
        ),
           SimpleDialogOption(
          child: const Text('他のクラスにログインする'),
          onPressed: () {
            Navigator.pop(context); 
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClassSelectionPage(
                ),
              ),
            );
          },
        ),
           SimpleDialogOption(
          child: const Text('他のメンバーでログインする'),
          onPressed: () {
            Navigator.pop(context); 
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SelectAccountPage(
                  classId: classInfo.id,
                  className: classInfo.name,
                ),
              ),
            );
          },
        ),
        // 追加:
        SimpleDialogOption(
          child: const Text('パスワードを変更する'),
          onPressed: () {
            Navigator.pop(context); // まずダイアログを閉じる

            // パスワード変更ダイアログを表示
            showDialog(
              context: context,
              builder: (context) {
                return ChangePasswordDialog(
                  classId: classInfo.id,
                  memberId: currentMemberId,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
