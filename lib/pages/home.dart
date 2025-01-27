import 'package:flutter/material.dart';
import 'package:school_memories2/pages/daialog.dart';
import 'package:school_memories2/pages/members_profile.dart';
import 'package:school_memories2/pages/message.dart';
import 'package:school_memories2/pages/myprofile.dart';
import 'package:school_memories2/pages/ranking.dart';
import '../class_model.dart';

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
    tabs = [
      MyProfilePage(
        classInfo: widget.classInfo,
        currentMemberId: widget.currentMemberId,
      ),
      ProfilePage(classId: widget.classInfo.id),
      MessagePage(classId: widget.classInfo.id, currentMemberId: widget.currentMemberId),
      RankingPage(classId: widget.classInfo.id),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'schoolmemories',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            Text(
              widget.classInfo.id,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => MainMemoriesDialog(
                  classInfo: widget.classInfo,
                  currentMemberId: widget.currentMemberId,
                ),
              );
            },
          ),
        ],
      ),
      body: tabs[currentIndex],
       bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (idx) => setState(() => currentIndex = idx),
        backgroundColor: Color(0xFF9ADBF0),
        selectedItemColor: Colors.white, // 選択中のアイコンとラベル
        unselectedItemColor: Colors.black54, // 非選択時のアイコンとラベル
        type: BottomNavigationBarType.fixed, // 背景色を固定
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
        ],
      ),
    );
  }
}