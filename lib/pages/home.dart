import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/class_model.dart';
import 'package:school_memories2/color.dart';
import 'package:school_memories2/pages/daialog.dart';
import 'package:school_memories2/pages/members_profile.dart';
import 'package:school_memories2/pages/members_profile_model.dart';
import 'package:school_memories2/pages/message.dart';
import 'package:school_memories2/pages/myprofile.dart';
import 'package:school_memories2/pages/myprofile_model.dart';
import 'package:school_memories2/pages/ranking.dart';
import 'package:school_memories2/pages/ranking_page_model.dart';
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

    // MyProfileModel の fetchProfileOnce を呼び出し
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileModel = Provider.of<MyProfileModel>(context, listen: false);
      profileModel.fetchProfileOnce(widget.classInfo.id, widget.currentMemberId);

      final membersModel =
          Provider.of<MembersProfileModel>(context, listen: false);
      membersModel.fetchClassMembers(widget.classInfo.id, widget.currentMemberId);

      // MessageModel の初期化
      final messageModel = Provider.of<MessageModel>(context, listen: false);
      messageModel.fetchMessages(widget.classInfo.id, widget.currentMemberId);

      final rankingModel =
          Provider.of<RankingPageModel>(context, listen: false);
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
    final membersModel = Provider.of<MembersProfileModel>(context);

    // 防御的記述を行った接続状態のストリーム
    final connectivityStream = Connectivity().onConnectivityChanged.map(
      (results) =>
          results.isNotEmpty ? results.first : ConnectivityResult.none,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: StreamBuilder<ConnectivityResult>(
          stream: connectivityStream,
          builder: (context, snapshot) {
            // オフラインの場合：シンプルな AppBar を表示
            if (snapshot.hasData &&
                snapshot.data == ConnectivityResult.none) {
              return AppBar(
                backgroundColor: Colors.grey[400],
                title: const Text(
                  'オフラインです',
                  style: TextStyle(color: Colors.white),
                ),
                centerTitle: true,
              );
            }
            // オンラインの場合：通常の AppBar を表示
            return AppBar(
              backgroundColor: Colors.white.withOpacity(0.5),
              elevation: 0,
              title: Text(
                'Sotsu Bun',
                style: GoogleFonts.dancingScript(
                    fontSize: 23, color: Colors.black),
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
            );
          },
        ),
      ),
      body: profileModel.isLoading || membersModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : tabs[currentIndex],
      // BottomNavigationBar を StreamBuilder でラップ
      bottomNavigationBar: StreamBuilder<ConnectivityResult>(
        stream: connectivityStream,
        initialData: ConnectivityResult.mobile,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data == ConnectivityResult.none) {
            // オフラインの場合は BottomNavigationBar を表示しない
            return const SizedBox.shrink();
          }
          // オンラインの場合は通常の BottomNavigationBar を表示
          return BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (idx) => setState(() => currentIndex = idx),
            selectedItemColor: darkBlueColor,
            unselectedItemColor: Colors.black,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle), label: 'マイページ'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.book), label: 'プロフィール'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.mail), label: 'よせがき'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.equalizer), label: 'ランキング'),
            ],
          );
        },
      ),
    );
  }
}
