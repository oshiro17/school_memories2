import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../signup/classselection_model.dart';
import 'daialog.dart';
import 'myprofile.dart';
import 'profile.dart';
import 'message.dart';
import 'ranking.dart';


class Home extends StatefulWidget {
  final Clas classInfo;

  const Home({required this.classInfo, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<Home> {
  late final Clas _class;
  int currentIndex = 0;
  late final List<Widget> tabs;

  @override
  void initState() {
    super.initState();
    _class = widget.classInfo;
    tabs = [
      MyProfilePage(),
      ProfilePage(),
      MessagePage(),
      RankingPage( Class(id: 'dummyClassId', name: 'Dummy Class'),), // 必要なクラス情報を渡す
    ];
  }

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_class.name}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
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
          backgroundColor: Colors.white,
      ),
      body: tabs[currentIndex],
     bottomNavigationBar: BottomNavigationBar(
  backgroundColor: Colors.white, // 背景色を設定
  selectedItemColor: Colors.blue, // 選択されたアイテムの色
  unselectedItemColor: Colors.grey, // 非選択時のアイテムの色
  selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), // 選択ラベルのスタイル
  unselectedLabelStyle: TextStyle(fontSize: 11), // 非選択ラベルのスタイル
  currentIndex: currentIndex,
  onTap: (index) => setState(() {
    currentIndex = index;
  }),
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'MyProfile',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.face),
      label: 'Profile',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.mail),
      label: 'Message',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.star),
      label: 'Ranking',
    ),
  ],
),

    );
  }
}
