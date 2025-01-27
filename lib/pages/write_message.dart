import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../class_model.dart';

class WritingMessagePage extends StatelessWidget {
  final SelectPeopleModel selectMember;

  const WritingMessagePage({
    Key? key,
    required this.selectMember,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController messageController = TextEditingController();
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('${selectMember.name} へメッセージ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: '寄せ書きメッセージを入力',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final text = messageController.text.trim();
                if (text.isEmpty) {
                  // 何も入力されていなければ何もしない
                  return;
                }

                try {
                  // 送信者の名前を取得する
                  final senderDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser?.uid)
                      .get();
                  final senderName = senderDoc.data()?['name'] ?? 'Unknown';

                  // Firestoreに書き込み
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(selectMember.id) // 受信者IDのドキュメント
                      .collection('messages') // サブコレクション
                      .add({
                    'message': text,
                    'senderId': currentUser?.uid ?? 'unknown',
                    'senderName': senderName, // 送信者の名前を追加
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  // 送信完了後、ひとつ前の画面に戻る
                  Navigator.pop(context);
                } catch (e) {
                  // エラー表示
                  await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('送信エラー'),
                      content: Text(e.toString()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('閉じる'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('送信する'),
            ),
          ],
        ),
      ),
    );
  }
}
