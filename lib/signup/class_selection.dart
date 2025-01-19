import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'login_model.dart';
import 'signup.dart';
import '../pages/home.dart';

class ClassselectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 仮フォーム
    final TextEditingController classIdController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('ClassselectionPage')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: classIdController, decoration: InputDecoration(labelText: 'クラスID')),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: 'パスワード')),
            SizedBox(height: 16),
            // クラス作成 → Homeへ
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Home(className: '新しく作ったクラス')),
                );
              },
              child: Text('クラスを作成'),
            ),
            SizedBox(height: 8),
            // クラスに参加 → Homeへ
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Home(className: '参加する既存クラス')),
                );
              },
              child: Text('クラスに参加'),
            ),
          ],
        ),
      ),
    );
  }
}