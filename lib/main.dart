import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/pages/setting_profile.dart';
import 'package:school_memories2/signup/class_selection_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingProfileModel()),
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
          // bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          //   backgroundColor: Color(0xFF9ADBF0),
          //   selectedItemColor: Colors.white, // 選択中アイテムの色
          //   unselectedItemColor: Colors.white70, // 非選択アイテムの色
          // ),
          // // ボタンのスタイル
          // elevatedButtonTheme: ElevatedButtonThemeData(
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Color(0xFF9ADBF0), // AppBarと合わせる
          //     foregroundColor: Colors.white,
          //     textStyle: const TextStyle(fontWeight: FontWeight.bold),
          //   ),
          // ),
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
