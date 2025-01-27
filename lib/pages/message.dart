import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagePage extends StatelessWidget {
  final String classId; // どのクラスか判別が必要なら

  const MessagePage({
    Key? key,
    required this.classId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ここでは、メッセージ表示を StreamBuilder 等で行う前に
    // 未送信メンバーチェック用の FutureBuilder を一つ設ける例

    return FutureBuilder<NotSentResult>(
      future: _fetchNotSentMembers(classId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('エラー: ${snapshot.error}')),
          );
        }

        final notSentResult = snapshot.data;
        final notSentMembers = notSentResult?.notSentMembers ?? [];

        // メインUI
        return Scaffold(
          body: Column(
            children: [
              // まだ送信していない相手がいる場合、警告表示
              if (notSentMembers.isNotEmpty)
                Container(
                  color: Colors.redAccent.withOpacity(0.2),
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    '${notSentMembers.map((m) => m.name).join(', ')} への送信がまだだよ！',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 8),

              // 受信メッセージ一覧（例: StreamBuilder）
              Expanded(
                child: _buildMessagesList(),
              ),
            ],
          ),
        );
      },
    );
  }

  /// まだ送信していないメンバーを取得するためのメソッド
  Future<NotSentResult> _fetchNotSentMembers(String classId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw 'ログインしていません。';
    }

    // クラスの全メンバー
    final memberSnap = await FirebaseFirestore.instance
        .collection('classes')
        .doc(classId)
        .collection('members')
        .get();
    final allMembers = memberSnap.docs.map((doc) {
      return SelectPeopleModel.fromMap(doc.data());
    }).toList();

    // 自分のsentList（このクラス向け）
    final sentSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('sentList')
        .where('classId', isEqualTo: classId)
        .get();
    final sentMemberIds = sentSnap.docs.map((doc) => doc.id).toSet();

    // 送信していないメンバーだけ抜き出す
    final notSentMembers = allMembers
        .where((m) => !sentMemberIds.contains(m.id))
        .toList();

    return NotSentResult(notSentMembers);
  }

  /// 受信メッセージ一覧を表示するウィジェットの例 (StreamBuilder)
  Widget _buildMessagesList() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('ログインしてください'));
    }

    // ここでは簡易的に users/{myUid}/messages を参照
    final messagesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: messagesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('エラー: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
            final dateTime = timestamp?.toDate();

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text(
                  messageText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('From: $senderName\n$dateTime'),
              ),
            );
          },
        );
      },
    );
  }
}

/// まだ送信していないメンバーをまとめる結果用クラス
class NotSentResult {
  final List<SelectPeopleModel> notSentMembers;

  NotSentResult(this.notSentMembers);
}

/// メンバー用のシンプルなモデル
class SelectPeopleModel {
  final String id;
  final String name;

  SelectPeopleModel({required this.id, required this.name});

  factory SelectPeopleModel.fromMap(Map<String, dynamic> map) {
    return SelectPeopleModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
    );
  }
}
