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
      create: (_) => MessageModel()..init(classId, currentMemberId),
      child: Scaffold(
        // 全体背景にグラデーションを設定
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFEFBA), Color(0xFFffffff)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Consumer<MessageModel>(
            builder: (context, model, child) {
              // ローディング中
              if (model.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // まだ送信していない状態
              if (!model.isSent) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'まだ寄せ書きを見ることはできません。\n'
                      'まずはメッセージを送信してください。',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.brown,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              }

              // メッセージが0件
              if (model.messages.isEmpty) {
                return const Center(
                  child: Text(
                    'まだメッセージがありません。',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                );
              }

              // メッセージがある場合: リスト表示 (プル・トゥ・リフレッシュ対応)
              return RefreshIndicator(
                onRefresh: () => model.fetchMessages(classId, currentMemberId, forceUpdate: true),
                child: ListView.builder(
                  // ListView の余白を少し調整
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  itemCount: model.messages.length,
                  itemBuilder: (context, index) {
                    final msg = model.messages[index];
                    final dateTime = msg.timestamp?.toDate();

                    return _buildMessageBubble(msg, dateTime);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// 吹き出し(チャットバブル)風のメッセージUIを作成
  ///  - 左: アバター画像 (assets/jX.png)
  ///  - 右: 吹き出しに入った (送信者名 + メッセージ + 日付)
  Widget _buildMessageBubble(MessageData msg, DateTime? dateTime) {
    return Container(
      // 全体マージン
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1) アイコン画像 (CircleAvatar で丸く表示)
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[300],
            backgroundImage: AssetImage('assets/j${msg.avatarIndex}.png'),
          ),
          const SizedBox(width: 12),
          // 2) 吹き出し部分
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              // 吹き出しの背景
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // (A) 送信者名
                  Text(
                    msg.senderName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // (B) メッセージ本文
                  Text(
                    msg.message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  // (C) 日付 (右下寄せ)
                  if (dateTime != null)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        _formatDateTime(dateTime),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 日付をいい感じにフォーマットする (例: "2023/08/03 19:24")
  String _formatDateTime(DateTime dateTime) {
    final y = dateTime.year.toString().padLeft(4, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    final hh = dateTime.hour.toString().padLeft(2, '0');
    final mm = dateTime.minute.toString().padLeft(2, '0');
    return '$y/$m/$d $hh:$mm';
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
    // すでに取得済み & forceUpdate = false なら何もしない
    if (isFetched && !forceUpdate) return;

    isLoading = true;
    notifyListeners();

    try {
      // 1) まず現在のメンバーdocを読んで isSent を確認
      final memberDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(memberId)
          .get();

      isSent = memberDoc.data()?['isSent'] ?? false;

      // 2) isSent == false ならメッセージリストは空のまま
      if (!isSent) {
        messages = [];
      } else {
        // 3) メッセージ一覧をtimestamp降順で取得
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
            // Firestoreフィールド名が "avatarIndex" の場合はここを変更
            avatarIndex: data['avatarIndex'] ?? 0,
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
  final int avatarIndex;
  final String message;
  final String senderName;
  final Timestamp? timestamp;

  MessageData({
    required this.avatarIndex,
    required this.message,
    required this.senderName,
    required this.timestamp,
  });
}
