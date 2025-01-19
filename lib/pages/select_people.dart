import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'write_message.dart';

enum ClassMemberAction { writeMessage, voteRanking }

class ClassMemberPage extends StatelessWidget {
  final ClassMemberAction action;
  const ClassMemberPage({required this.action});

  @override
  Widget build(BuildContext context) {
    // 仮のメンバーリスト
    final List<String> members = ['山田', '鈴木', '田中'];

    return Scaffold(
      appBar: AppBar(title: Text('クラスメイト一覧')),
      body: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          final memberName = members[index];
          return ListTile(
            title: Text(memberName),
            onTap: () {
              if (action == ClassMemberAction.writeMessage) {
                // メッセージ作成画面へ
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WritingMessagePage(memberName: memberName)),
                );
              } else {
                // 投票用ダイアログ
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('投票'),
                      content: Text('$memberName に投票しますか？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, ''), // キャンセル
                          child: Text('キャンセル'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);         // ダイアログを閉じる
                            Navigator.pop(context, memberName); // ClassMemberPageを閉じて投票先を返す
                          },
                          child: Text('投票する'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}