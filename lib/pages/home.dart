import 'package:flutter/material.dart';
import 'package:school_memories2/color.dart';
import 'package:school_memories2/pages/daialog.dart';
import 'package:school_memories2/pages/members_profile.dart';
import 'package:school_memories2/pages/message.dart';
import 'package:school_memories2/pages/myprofile.dart';
import 'package:school_memories2/pages/ranking.dart';
import '../class_model.dart';
import 'package:google_fonts/google_fonts.dart';

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
      ProfilePage(classInfo: widget.classInfo,currentMemberId: widget.currentMemberId),
      MessagePage(classId: widget.classInfo.id, currentMemberId: widget.currentMemberId),
      RankingPage(classId: widget.classInfo.id, currentMemberId: widget.currentMemberId),
    ];
  }

  @override
  Widget build(BuildContext context) {
      print('classInfo.name: ${widget.classInfo.name}');
    return Scaffold(
   extendBodyBehindAppBar: true, 
    appBar: AppBar(
  backgroundColor: Colors.white.withOpacity(0.5),
  elevation: 0, // 影をなくす
  // bottom: PreferredSize(
  //   preferredSize: const Size.fromHeight(1.0), // ボーダーの高さ
  //   child: Container(
  //     color: Colors.black, // ボーダーの色
  //     height: 1.0, // ボーダーの太さ
  //   ),
  // ),
  title: 
        Text(
          'School Memories',
          style: GoogleFonts.dancingScript(
            fontSize: 23,
            color: Colors.black
            
            
    ,
          ),
        ),
  //     ],
  //   ),
  // ),
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
        selectedItemColor: darkBlueColor, // 選択中のアイコンとラベル
        unselectedItemColor: Colors.black, // 非選択時のアイコンとラベル
        type: BottomNavigationBarType.fixed, // 背景色を固定
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'マイページ'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'プロフィール'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'よせがき'),
          BottomNavigationBarItem(icon: Icon(Icons.equalizer), label: 'ランキング'),
        ],
      ),
    );
  }
}
