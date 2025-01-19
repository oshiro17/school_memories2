import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class MessagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 右下ボタンで ClassMemberPage(action=writeMessage) へ遷移
    return Scaffold(
      body: Center(
        child: Text('MessagePage'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => ClassMemberPage(action: ClassMemberAction.writeMessage),
        //     ),
        //   );
        },
      ),
    );
  }
}