import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'daialog.dart';
import 'myprofile.dart';
import 'profile.dart';
import 'message.dart';
import 'ranking.dart';

class Home extends StatefulWidget {
  final String className;
  const Home({required this.className});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;

  // 切り替えるタブ画面をまとめる
  final List<Widget> tabs = [
    MyProfilePage(),
    ProfilePage(),
    MessagePage(),
    RankingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.className} の卒業文集'),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              // メニューダイアログを表示
              showDialog(
                context: context,
                builder: (context) => MainMemoriesDialog(),
              );
            },
          ),
        ],
      ),
      body: tabs[currentIndex], // 選択されたタブの画面を表示
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() {
          currentIndex = index;
        }),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'MyProfile'),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Message'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Ranking'),
        ],
      ),
    );
  }
}