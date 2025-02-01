import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          return const Center(child: CircularProgressIndicator());
        }

        if (!model.isSent) {
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

        // AppBarの高さ分の余白を追加
        return RefreshIndicator(
          onRefresh: () => model.fetchMessages(classId, currentMemberId, forceUpdate: true),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            itemCount: model.messages.length + 1, // SizedBox分を考慮
            itemBuilder: (context, index) {
              if (index == 0) {
                return const SizedBox(height: kToolbarHeight); // AppBarの高さ分の余白
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1) アバター画像
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
                  // (C) 日付
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


class MessageModel extends ChangeNotifier {
  bool isSent = false;
  bool isLoading = false;
  bool isFetched = false;
  List<MessageData> messages = [];

  /// Firestoreからメッセージを取得（初回 or プル・トゥ・リフレッシュ時のみ実行）
  Future<void> fetchMessages(String classId, String memberId, {bool forceUpdate = false}) async {
  
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'messages_${classId}_$memberId';

   if (!forceUpdate) {
  final cachedData = prefs.getString(cacheKey);
  
  if (cachedData != null) {
    print("キャッシュデータが存在します: $cachedData");
    try {
      final cachedMessages = json.decode(cachedData) as List;
      messages = cachedMessages.map((e) => MessageData.fromJson(e)).toList();
      isFetched = true;
      notifyListeners();
      print("キャッシュデータの読み込みに成功しました。");
      isSent = true;
      return;
    } catch (e) {
      print("キャッシュデータのデコードに失敗しました: $e");
    }
  } else {
    print("キャッシュデータが存在しません。");
  }
}


    // Firebaseから取得
    isLoading = true;
    notifyListeners();
print('kitakitakitakitatkita');
    try {
      // 1) メンバーのisSentフラグ確認
      final memberDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(memberId)
          .get();

      isSent = memberDoc.data()?['isSent'] ?? false;

      if (isSent) {
        // 2) メッセージの取得
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
            message: data['message'] ?? '',
            senderName: data['senderName'] ?? 'Unknown',
            timestamp: data['timestamp'] as Timestamp?,
          );
        }).toList();

        // 3) 取得したデータをキャッシュに保存
        await prefs.setString(cacheKey, json.encode(messages.map((msg) => msg.toJson()).toList()));
      } else {
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

  /// 初回呼び出し用メソッド
  // void init(String classId, String memberId) {
  //   fetchMessages(classId, memberId);
  // }
}

/// メッセージデータクラス
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

  // JSONからの復元
  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
      avatarIndex: json['avatarIndex'],
      message: json['message'],
      senderName: json['senderName'],
      timestamp: json['timestamp'] != null
          ? Timestamp.fromMillisecondsSinceEpoch(json['timestamp'])
          : null,
    );
  }

  // JSONへの変換
  Map<String, dynamic> toJson() {
    return {
      'avatarIndex': avatarIndex,
      'message': message,
      'senderName': senderName,
      'timestamp': timestamp?.millisecondsSinceEpoch,
    };
  }
}
