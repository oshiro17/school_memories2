import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ログイン中ユーザー（= このメッセージ一覧を見ている人 = 受信者）
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // 未ログインの場合（基本的にあり得ない想定なら適当でOK）
      return const Center(child: Text('ログインしてください'));
    }

    // Firestoreのコレクションをリアルタイムで監視する
    final messagesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('messages')
        .orderBy('timestamp', descending: true) // 新しい順に並べる例
        .snapshots();

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: messagesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('まだ寄せ書きがありません'));
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final messageText = data['message'] ?? '';
              final senderName = data['senderName'] ?? 'Unknown';
              final timestamp = data['timestamp'] as Timestamp?;
              final dateTime = timestamp?.toDate().toLocal();

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    messageText,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'From: $senderName\nTime: ${dateTime ?? '-'}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
