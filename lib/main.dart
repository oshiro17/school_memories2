import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/color.dart';
import 'package:school_memories2/pages/members_profile_model.dart';
import 'package:school_memories2/pages/message.dart';
import 'package:school_memories2/pages/myprofile_model.dart';
import 'package:school_memories2/pages/setting_profile.dart';
import 'package:school_memories2/signup/class_selection_page.dart';
// const Color goldColor = Color(0xFFFFD700);
// const Color blackColor = Color(0xFF000000);
// const Color darkBlueColor = Color(0xFF1E3A8A);
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
            primaryColor: darkBlueColor,
        // scaffoldBackgroundColor: blackColor,
          // 全体のテーマカラー: 青春感のあるパステルブルー
          // primarySwatch:Color.fromARGB(255, 95, 44, 234), 
          // AppBarのテーマ
          appBarTheme: const AppBarTheme(
          // backgroundColor: goldColor,
          foregroundColor: blackColor,
          ),
          // ボタンのスタイル
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: darkBlueColor, // AppBarと合わせる
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
