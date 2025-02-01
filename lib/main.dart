import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/color.dart';
import 'package:school_memories2/pages/members_profile_model.dart';
import 'package:school_memories2/pages/message.dart';
import 'package:school_memories2/pages/myprofile_model.dart';
import 'package:school_memories2/pages/setting_profile.dart';
import 'package:school_memories2/signup/class_selection_page.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 追加

import '../class_model.dart';
import '../pages/home.dart';

// const Color goldColor = Color(0xFFFFD700);
// const Color blackColor = Color(0xFF000000);
// const Color darkBlueColor = Color(0xFF1E3A8A);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // --- ここで SharedPreferences を読み込む ---
  final prefs = await SharedPreferences.getInstance();
  final savedClassId = prefs.getString('savedClassId');
  final savedMemberId = prefs.getString('savedMemberId');

  // 初期画面 (Widget) を決める変数
  Widget firstPage;

  if (savedClassId != null && savedMemberId != null) {
    // すでに保存情報があれば、Home画面を初期画面に設定
    // ただし本当は Firestore にそのクラスやメンバーが存在するか確認するとさらに安全
    final classInfo = ClassModel(
      id: savedClassId,
      name: '', // クラス名の保持が必要であれば、同様にSharedPreferencesに保存しておく
    );
    firstPage = Home(
      classInfo: classInfo,
      currentMemberId: savedMemberId,
    );
  } else {
    // 保存情報が無ければ、従来どおり ClassSelectionPage へ
    firstPage = const ClassSelectionPage();
  }

  runApp(MyApp(firstPage: firstPage));
}

class MyApp extends StatelessWidget {
  // 追加: 初期画面を受け取る
  final Widget firstPage;
  const MyApp({super.key, required this.firstPage});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MyProfileModel>(
          create: (_) => MyProfileModel(),
        ),
        ChangeNotifierProvider(create: (_) => SettingProfileModel()),
        ChangeNotifierProvider(create: (_) => MembersProfileModel()),
           ChangeNotifierProvider<MessageModel>(create: (_) => MessageModel()),
      ],
      child: MaterialApp(
        title: 'School Memories',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: darkBlueColor,
          appBarTheme: const AppBarTheme(
            foregroundColor: blackColor,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: darkBlueColor,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        // home を差し替え
        home: firstPage,
      ),
    );
  }
}
