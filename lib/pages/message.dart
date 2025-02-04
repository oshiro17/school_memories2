import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageModel extends ChangeNotifier {
  bool isSent = false;
  bool isLoading = false;
  bool isFetched = false;
  List<MessageData> messages = [];
  String? errorMessage; // エラー状態を保持するフィールド

  /// Firestoreからメッセージを取得
  Future<void> fetchMessages(String classId, String memberId, {bool forceUpdate = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'messages_${classId}_$memberId';
    errorMessage = null;
    if (!forceUpdate) {
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        try {
          final cachedMessages = json.decode(cachedData) as List;
          messages = cachedMessages.map((e) => MessageData.fromJson(e)).toList();
          isFetched = true;
          isSent = true;
          notifyListeners();
          return;
        } catch (e) {
          print("キャッシュデータのデコードに失敗しました: $e");
        }
      }
    }

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

        await prefs.setString(
          cacheKey,
          json.encode(messages.map((msg) => msg.toJson()).toList()),
        );
      } else {
        messages = [];
      }
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        errorMessage = 'ネットワークエラーです。';
        // 例: navigatorKey.currentState?.pushAndRemoveUntil(OfflinePage(...), (route)=>false);
      } else {
        errorMessage = 'Firestoreエラー: ${e.message}';
      }
      print('メッセージ取得中にエラーが発生: $e');
    } catch (e) {
      errorMessage = 'メッセージ取得中にエラーが発生しました: $e';
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
  final String likeMessage;
  final String requestMessage;
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

            // エラー状態がある場合はエラーメッセージと再試行ボタンを表示
            if (model.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      model.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await model.fetchMessages(classId, currentMemberId, forceUpdate: true);
                      },
                      child: const Text('再試行'),
                    ),
                  ],
                ),
              );
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

            // Connectivity の状態を監視して、オフラインの場合はリフレッシュ処理を無効化する
            return StreamBuilder<ConnectivityResult>(
              stream: Connectivity().onConnectivityChanged.map(
                (results) => results.isNotEmpty ? results.first : ConnectivityResult.none,
              ),
              builder: (context, snapshot) {
                // snapshot.data が null の場合はオンラインと仮定（例: ConnectivityResult.mobile）
                final connectivityResult = snapshot.data ?? ConnectivityResult.mobile;
                final offline = connectivityResult == ConnectivityResult.none;
                return RefreshIndicator(
                  onRefresh: offline
                      ? () async {
                          // オフラインの場合は何もしないダミーの Future を返す
                          return;
                        }
                      : () async => await model.fetchMessages(
                          classId, currentMemberId, forceUpdate: true),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    itemCount: model.messages.length + 1, // 先頭にAppBar分の余白用
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
            );
          },
        ),
      ),
     floatingActionButton: StreamBuilder<ConnectivityResult>(
  stream: Connectivity().onConnectivityChanged.map(
    (results) => results.isNotEmpty ? results.first : ConnectivityResult.none,
  ),
  builder: (context, snapshot) {
    // snapshot.data が null の場合はオンラインと仮定（例: ConnectivityResult.mobile）
    final connectivityResult = snapshot.data ?? ConnectivityResult.mobile;
    final offline = connectivityResult == ConnectivityResult.none;
    return FloatingActionButton(
      // オフラインの場合は背景色をグレーに変更
      backgroundColor: offline ? Colors.grey : goldColor,
      // オンラインの場合のみ onPressed を設定し、オフラインの場合は null にすることで無効化
      onPressed: () {
          final model = Provider.of<MessageModel>(context, listen: false);
          model.fetchMessages(classId, currentMemberId, forceUpdate: true);
        },
      child: const Icon(Icons.refresh),
    );
  },
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
                        msg.message,
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
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
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
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(0, 15);
    path.lineTo(6, 10);
    path.lineTo(6, 20);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BubblePainter oldDelegate) => false;
}
