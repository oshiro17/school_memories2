
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WritingMessagePage extends StatelessWidget {
  final String memberName;
  const WritingMessagePage({required this.memberName});

  @override
  Widget build(BuildContext context) {
    final TextEditingController messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('$memberName へ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: messageController,
              maxLines: 5,
              decoration: InputDecoration(labelText: 'メッセージを入力'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // メッセージ作成処理後、ClassMemberPageへ戻る
                Navigator.pop(context);
              },
              child: Text('作成する'),
            ),
          ],
        ),
      ),
    );
  }
}