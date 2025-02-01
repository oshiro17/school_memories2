import 'package:flutter/material.dart';
import 'package:school_memories2/class_model.dart';
import 'package:school_memories2/pages/change_password_dialog.dart';
import 'package:school_memories2/pages/write_message.dart';
import 'package:school_memories2/pages/vote.dart';
import 'package:school_memories2/signup/class_selection_page.dart';
import 'package:school_memories2/signup/select_account_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
            Navigator.pop(context);
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
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('savedClassId');
            await prefs.remove('savedMemberId');
            await prefs.remove('savedClassName');
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClassSelectionPage(),
              ),
            );
          },
        ),
        SimpleDialogOption(
          child: const Text('他のメンバーでログインする'),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('savedMemberId');
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
        SimpleDialogOption(
          child: const Text('パスワードを変更する'),
          onPressed: () {
            Navigator.pop(context);
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
        SimpleDialogOption(
          child: const Text('お問い合わせ'),
          onPressed: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('お問い合わせ'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('メール: nonokuwapiano@gmail.com'),
                      SizedBox(height: 8),
                      Text('Twitter: @ora_nonoka'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('閉じる'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
