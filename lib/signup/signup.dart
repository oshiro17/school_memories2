import 'login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'class_selection.dart';

class SignupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 仮のTextEditingControllerなど
    final TextEditingController mailController = TextEditingController();
    final TextEditingController passController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('SignUpPage')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: mailController, decoration: InputDecoration(labelText: 'New Email')),
            TextField(controller: passController, decoration: InputDecoration(labelText: 'New Password')),
            SizedBox(height: 16),
            // 新規登録後 → ClassselectionPage
            ElevatedButton(
              onPressed: () {
                // ここで登録処理を行う想定
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClassselectionPage()),
                );
              },
              child: Text('新規登録'),
            ),
          ],
        ),
      ),
    );
  }
}