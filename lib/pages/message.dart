import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// メッセージ一覧を表示するページ
class MessagePage extends StatelessWidget {
  final String classId;
  final String currentMemberId;

  const MessagePage({
    Key? key,
    required this.classId,
    required this.currentMemberId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MessageModel>(
      create: (_) => MessageModel()..init(classId, currentMemberId), // 最初の1回だけ実行
      child: Scaffold(
        body: Consumer<MessageModel>(
          builder: (context, model, child) {
            if (model.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!model.isSent) {
              return const Center(
                child: Text(
                  'まだ寄せ書きを見ることはできません。\nメッセージを送信してください。',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              );
            }

            if (model.messages.isEmpty) {
              return const Center(
                child: Text('まだメッセージがありません。'),
              );
            }

            return RefreshIndicator(
              onRefresh: () => model.fetchMessages(classId, currentMemberId, forceUpdate: true), // プル・トゥ・リフレッシュ対応
              child: ListView.builder(
                itemCount: model.messages.length,
                itemBuilder: (context, index) {
                  final msg = model.messages[index];
                  final dateTime = msg.timestamp?.toDate();

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(
                        msg.senderName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(msg.message),
                          if (dateTime != null)
                            Text(
                              dateTime.toString(),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/// メッセージ表示のためのデータモデルと取得処理を担当
class MessageModel extends ChangeNotifier {
  bool isSent = false;
  bool isLoading = false;
  bool isFetched = false; // 最初の1回のみ取得するフラグ
  List<MessageData> messages = [];

  /// Firestoreからメッセージを取得（初回 or プル・トゥ・リフレッシュ時のみ実行）
  Future<void> fetchMessages(String classId, String memberId, {bool forceUpdate = false}) async {
    if (isFetched && !forceUpdate) return; 
    print("デバッグ: メッセージを表示");
// すでに取得済みならスキップ

    isLoading = true;
    notifyListeners();

    try {
      final memberDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(memberId)
          .get();

      isSent = memberDoc.data()?['isSent'] ?? false;

      // `isSent == false` の場合は Firestore にアクセスしない
      if (!isSent) {
        messages = [];
      } else {
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
            timestamp: data['timestamp'] as Timestamp?,
          );
        }).toList();
      }
    } catch (e) {
      print('メッセージ取得中にエラーが発生: $e');
    } finally {
      isLoading = false;
      isFetched = true; // 初回取得フラグを設定
      notifyListeners();
    }
  }

  /// 初回のみ `fetchMessages` を実行するメソッド
  void init(String classId, String memberId) {
    fetchMessages(classId, memberId);
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
