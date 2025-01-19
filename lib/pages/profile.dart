import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'each_profile.dart';
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // メンバーカードタップで EachProfilePage へ遷移 など
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text('山田のプロフィールへ'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EachProfilePage()),
            );
          },
        ),
      ),
    );
  }
}