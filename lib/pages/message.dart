import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


/// メッセージ一覧を表示するページ
class MessagePage extends StatelessWidget {
  final String classId;        // どのクラスか判別するためのID
  final String currentMemberId; // 自分のメンバーID

  const MessagePage({
    Key? key,
    required this.classId,
    required this.currentMemberId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MessageModel>(
      create: (_) => MessageModel()..fetchMessages(classId, currentMemberId),
      child: Scaffold(
        body: Consumer<MessageModel>(
          builder: (context, model, child) {
            if (model.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (model.messages.isEmpty) {
              return const Center(
                child: Text('まだメッセージがありません。'),
              );
            }

            // 取得したメッセージをListViewで表示
            return ListView.builder(
              itemCount: model.messages.length,
              itemBuilder: (context, index) {
                final msg = model.messages[index];
                final dateTime = msg.timestamp?.toDate();

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(
                      msg.senderName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(msg.message),
                        if (dateTime != null)
                          Text(
                            dateTime.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// メッセージ表示のためのデータモデルと取得処理を担当
class MessageModel extends ChangeNotifier {
  bool isLoading = false;
  List<MessageData> messages = [];

  /// Firestoreからメッセージを取得するメソッド
  Future<void> fetchMessages(String classId, String memberId) async {
    isLoading = true;
    notifyListeners();

    try {
      // /classes/{classId}/members/{memberId}/messages をタイムスタンプ降順で取得
      final snapshot = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(memberId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .get();

      messages = snapshot.docs.map((doc) {
        final data = doc.data();
        return MessageData(
          message: data['message'] ?? '',
          senderName: data['senderName'] ?? 'Unknown',
          timestamp: data['timestamp'] as Timestamp?, // nullの可能性があるため型チェック
        );
      }).toList();
    } catch (e) {
      print('メッセージ取得中にエラーが発生: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

/// メッセージ1件分のデータを表すクラス
class MessageData {
  final String message;
  final String senderName;
  final Timestamp? timestamp;

  MessageData({
    required this.message,
    required this.senderName,
    required this.timestamp,
  });
}
