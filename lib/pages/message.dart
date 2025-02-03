import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 寄せ書きのメッセージを表示する画面
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
    final model = Provider.of<MessageModel>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFFFEBEE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Builder(
          builder: (context) {
            if (model.isLoading) {
              // 読み込み中
              return const Center(child: CircularProgressIndicator());
            }

            if (!model.isSent) {
              // まだ送信していない（isSent = false）場合
              return const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 57, left: 7, right: 7),
                  child: Text(
                    'まだ寄せ書きを見ることはできません。\n'
                    'まずはメッセージを送信してください。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                ),
              );
            }

            if (model.messages.isEmpty) {
              // 送信したが他のメンバーからのメッセージがない場合
              return const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 57, left: 7, right: 7),
                  child: Text(
                    'まだメッセージがありません。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                ),
              );
            }

            // メッセージがある場合、Pull-to-refresh 付きの ListView で表示
            return RefreshIndicator(
              onRefresh: () =>
                  model.fetchMessages(classId, currentMemberId, forceUpdate: true),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                itemCount: model.messages.length + 1, // 最初にAppBar分の余白用
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const SizedBox(height: kToolbarHeight);
                  }
                  final msg = model.messages[index - 1];
                  final dateTime = msg.timestamp?.toDate();
                  return _buildMessageBubble(msg, dateTime);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: goldColor,
        onPressed: () {
          final model = Provider.of<MessageModel>(context, listen: false);
          model.fetchMessages(classId, currentMemberId, forceUpdate: true);
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  /// メッセージの吹き出しUI
  Widget _buildMessageBubble(MessageData msg, DateTime? dateTime) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1) アバター画像
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            backgroundImage: AssetImage('assets/j${msg.avatarIndex}.png'),
          ),
          const SizedBox(width: 16),
          // 2) 吹き出し本体（カスタムペインで尻尾をつける）
          Expanded(
            child: CustomPaint(
              painter: BubblePainter(),
              child: Container(
                // 塗りつぶしの余白（尻尾が含まれるのでpadding多め）
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFFF1F1F1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
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
                        color: darkBlueColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // (B) 3種類のメッセージをそれぞれ表示
                    if (msg.likeMessage.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.favorite, color: Colors.pink, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '君の好きなところ,すごいところ',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                     Text(
                              msg.likeMessage,
                              style: const TextStyle(fontSize: 14),
                            ), 
                            const SizedBox(height: 8),
                    ],
                    if (msg.requestMessage.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.volunteer_activism, color: Colors.blue, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '君へのお願いごと',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                     Text(
                             msg.requestMessage,
                              style: const TextStyle(fontSize: 14),
                            ), 
                            const SizedBox(height: 8),
                    ],
                    if (msg.message.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.history_edu, color: darkBlueColor, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '君へのメッセージ',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                              msg.likeMessage,
                              style: const TextStyle(fontSize: 14),
                            ), 
                            const SizedBox(height: 8),
                    ],

                    // (C) 日時（右下に表示）
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
          ),
        ],
      ),
    );
  }

  /// 日付のフォーマット
  String _formatDateTime(DateTime dateTime) {
    final y = dateTime.year.toString().padLeft(4, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    final hh = dateTime.hour.toString().padLeft(2, '0');
    final mm = dateTime.minute.toString().padLeft(2, '0');
    return '$y/$m/$d $hh:$mm';
  }
}

/// CustomPainterを使って吹き出しの「尻尾」を描画する
class BubblePainter extends CustomPainter {
  final Color color;
  final double radius;

  BubblePainter({
    this.color = Colors.white,
    this.radius = 16,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 吹き出しの尻尾のパスを描く
    // 左端に三角形状の尻尾をつけるイメージ
    final paint = Paint()..color = color;
    final path = Path();
    // 三角形の頂点を適当に決める
    // (0, 15) → (6, 10) → (6, 20) の三角形
    path.moveTo(0, 15);
    path.lineTo(6, 10);
    path.lineTo(6, 20);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BubblePainter oldDelegate) => false;
}

/// MessageModel: メッセージ一覧を管理するProvider用モデル
class MessageModel extends ChangeNotifier {
  bool isSent = false;
  bool isLoading = false;
  bool isFetched = false;
  List<MessageData> messages = [];

  /// Firestoreからメッセージを取得
  Future<void> fetchMessages(String classId, String memberId, {bool forceUpdate = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'messages_${classId}_$memberId';

    // キャッシュがあれば優先的に読み込む（forceUpdateがfalseの場合）
    if (!forceUpdate) {
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        try {
          final cachedMessages = json.decode(cachedData) as List;
          messages = cachedMessages.map((e) => MessageData.fromJson(e)).toList();
          isFetched = true;
          isSent = true; // キャッシュありということは以前送信済み
          notifyListeners();
          return;
        } catch (e) {
          print("キャッシュデータのデコードに失敗しました: $e");
        }
      }
    }

    // ここからFirestoreへアクセス
    isLoading = true;
    notifyListeners();

    try {
      // (1) 自分の isSent フラグ確認
      final memberDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(memberId)
          .get();
      isSent = memberDoc.data()?['isSent'] ?? false;

      // (2) もし isSent = true なら、実際にメッセージ群を取得
      if (isSent) {
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
            avatarIndex: data['avatarIndex'] ?? 0,
            likeMessage: data['likeMessage'] ?? '',
            requestMessage: data['requestMessage'] ?? '',
            message: data['message'] ?? '',
            senderName: data['senderName'] ?? 'Unknown',
            timestamp: data['timestamp'] as Timestamp?,
          );
        }).toList();

        // (3) キャッシュ保存
        await prefs.setString(
          cacheKey,
          json.encode(messages.map((msg) => msg.toJson()).toList()),
        );
      } else {
        // まだ送信していない場合はメッセージなし
        messages = [];
      }
    } catch (e) {
      print('メッセージ取得中にエラーが発生: $e');
    } finally {
      isLoading = false;
      isFetched = true;
      notifyListeners();
    }
  }
}

/// メッセージ1件分のデータクラス
class MessageData {
  final int avatarIndex;

  /// 「好きなところ・すごいところ」
  final String likeMessage;

  /// 「お願い事」
  final String requestMessage;

  /// 「個別メッセージ」
  final String message;

  final String senderName;
  final Timestamp? timestamp;

  MessageData({
    required this.avatarIndex,
    required this.likeMessage,
    required this.requestMessage,
    required this.message,
    required this.senderName,
    required this.timestamp,
  });

  // JSONからの復元
  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
      avatarIndex: json['avatarIndex'] ?? 0,
      likeMessage: json['likeMessage'] ?? '',
      requestMessage: json['requestMessage'] ?? '',
      message: json['message'] ?? '',
      senderName: json['senderName'] ?? 'Unknown',
      timestamp: json['timestamp'] != null
          ? Timestamp.fromMillisecondsSinceEpoch(json['timestamp'])
          : null,
    );
  }

  // JSONへの変換
  Map<String, dynamic> toJson() {
    return {
      'avatarIndex': avatarIndex,
      'likeMessage': likeMessage,
      'requestMessage': requestMessage,
      'message': message,
      'senderName': senderName,
      'timestamp': timestamp?.millisecondsSinceEpoch,
    };
  }
}
