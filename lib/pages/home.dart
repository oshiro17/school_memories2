import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/color.dart';
import 'package:school_memories2/pages/daialog.dart';
import 'package:school_memories2/pages/members_profile.dart';
import 'package:school_memories2/pages/members_profile_model.dart';
import 'package:school_memories2/pages/message.dart';
import 'package:school_memories2/pages/myprofile.dart';
import 'package:school_memories2/pages/myprofile_model.dart';
import 'package:school_memories2/pages/ranking.dart';
import 'package:school_memories2/pages/ranking_page_model.dart';
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

    // MyProfileModelのfetchProfileOnceを呼び出し
     WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileModel = Provider.of<MyProfileModel>(context, listen: false);
      profileModel.fetchProfileOnce(widget.classInfo.id, widget.currentMemberId);

      final membersModel = Provider.of<MembersProfileModel>(context, listen: false);
      membersModel.fetchClassMembers(widget.classInfo.id, widget.currentMemberId);

      // MessageModel の初期化
      final messageModel = Provider.of<MessageModel>(context, listen: false);
      messageModel.fetchMessages(widget.classInfo.id, widget.currentMemberId);

       final rankingModel = Provider.of<RankingPageModel>(context, listen: false);
      rankingModel.init(widget.classInfo.id, widget.currentMemberId);
    });
    // タブの初期化
    tabs = [
      MyProfilePage(
        classInfo: widget.classInfo,
        currentMemberId: widget.currentMemberId,
      ),
      ProfilePage(
        classInfo: widget.classInfo,
        currentMemberId: widget.currentMemberId,
      ),
      MessagePage(
        classId: widget.classInfo.id,
        currentMemberId: widget.currentMemberId,
      ),
      RankingPage(
        classId: widget.classInfo.id,
        currentMemberId: widget.currentMemberId,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final profileModel = Provider.of<MyProfileModel>(context);
    final membersModel = Provider.of<MembersProfileModel>(context); // 追加

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.5),
        elevation: 0,
        title: Text(
          'Sotsu Bun',
          style: GoogleFonts.dancingScript(fontSize: 23, color: Colors.black),
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
      body: profileModel.isLoading || membersModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : tabs[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (idx) => setState(() => currentIndex = idx),
        selectedItemColor: darkBlueColor,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
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