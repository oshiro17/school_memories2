import 'package:flutter/material.dart';
import 'package:school_memories2/class_model.dart';
import 'package:school_memories2/pages/daialog.dart';
import 'package:school_memories2/pages/members_profile.dart';
import 'package:school_memories2/pages/message.dart';
import 'package:school_memories2/pages/myprofile.dart';
import 'package:school_memories2/pages/ranking.dart';

class Home extends StatefulWidget {
  final ClassModel classInfo;
  final String currentMemberId;

  const Home({
    Key? key,
    required this.classInfo,
    required this.currentMemberId,
  }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;
  late final List<Widget> tabs;

  @override
  void initState() {
    super.initState();
    // 各タブで自分のmemberIdを使いたい場合に渡す
    tabs = [
      MyProfilePage(
        classInfo: widget.classInfo,
        currentMemberId: widget.currentMemberId,
      ),
      ProfilePage(classId: widget.classInfo.id),
      MessagePage(classId: widget.classInfo.id, currentMemberId: widget.currentMemberId),
      RankingPage(classId: widget.classInfo.id, currentMemberId: widget.currentMemberId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        title: Text(
          widget.classInfo.id,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu), // メニューアイコンを表示
            onPressed: () {
              // メニューダイアログを表示
              showDialog(
                context: context,
                builder: (context) => MainMemoriesDialog(classInfo: widget.classInfo,currentMemberId : widget.currentMemberId),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: tabs[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (idx) => setState(() => currentIndex = idx),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'MyProfile'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Members'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Ranking'),
        ],
      ),
    );
  }
}

