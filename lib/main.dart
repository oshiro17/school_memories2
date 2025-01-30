import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/pages/members_profile_model.dart';
import 'package:school_memories2/pages/message.dart';
import 'package:school_memories2/pages/myprofile_model.dart';
import 'package:school_memories2/pages/setting_profile.dart';
import 'package:school_memories2/signup/class_selection_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
          // 1) MyProfileModel ... (自分のプロフィールを一度取得)
        ChangeNotifierProvider<MyProfileModel>(
          create: (_) => MyProfileModel(),
        ),
        ChangeNotifierProvider(create: (_) => SettingProfileModel()),
           ChangeNotifierProvider(create: (_) => MembersProfileModel()),
      ],
      child: MaterialApp(
        title: 'School Memories',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // 全体のテーマカラー: 青春感のあるパステルブルー
          primarySwatch: Colors.lightBlue,
          // AppBarのテーマ
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF9ADBF0), // 淡い水色
            foregroundColor: Colors.white, // 文字色
            elevation: 0,
            titleTextStyle: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          // ボタンのスタイル
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF9ADBF0), // AppBarと合わせる
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        home: const ClassSelectionPage(),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
