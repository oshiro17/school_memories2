import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class MessagePage extends StatelessWidget {
  // サンプルデータ
  final List<Map<String, String>> messages = [
    {
      'message': 'こんにちは一緒に勉強しましょう！',
      'username': 'Taro',
      'iconUrl': 'https://via.placeholder.com/150',
    },
    {
      'message': '明日の授業はどうでしたか？',
      'username': 'Hanako',
      'iconUrl': 'https://via.placeholder.com/150',
    },
    {
      'message': 'いい天気ですね！',
      'username': 'Yuki',
      'iconUrl': 'https://via.placeholder.com/150',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PageView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final messageData = messages[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // メッセージ本文
                    Text(
                      messageData['message']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    // ユーザー情報
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 丸いアイコン
                        CircleAvatar(
                          radius: 24.0,
                          backgroundImage: NetworkImage(messageData['iconUrl']!),
                        ),
                        const SizedBox(width: 12.0),
                        // ユーザーネーム
                        Text(
                          messageData['username']!,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
