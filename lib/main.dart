// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:provider/provider.dart';
// import 'package:school_memories2/color.dart';
// import 'package:school_memories2/pages/members_profile_model.dart';
// import 'package:school_memories2/pages/message.dart';
// import 'package:school_memories2/pages/myprofile_model.dart';
// import 'package:school_memories2/pages/ranking_page_model.dart';
// import 'package:school_memories2/pages/setting_profile.dart';
// import 'package:school_memories2/signup/class_selection_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../class_model.dart';
// import '../pages/home.dart';
// import 'offline_page.dart'; // OfflinePage の import（上記 OfflinePage のコードがあるファイル）

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // ※ オフラインテスト用のフラグ（実際はネットワーク切断時に Firebase.initializeApp() で例外が発生します）
//   // const bool simulateOffline = true;

//   try {
//     if (simulateOffline) {
//       throw Exception("Simulated offline error");
//     } else {
//       await Firebase.initializeApp();
//     }
//   } catch (e) {
//     // Firebase 初期化に失敗した場合、OfflinePage を表示
//     runApp(OfflinePage(error: e.toString()));
//     return;
//   }

//   // Firebase 初期化成功後
//   final prefs = await SharedPreferences.getInstance();
//   final savedClassId = prefs.getString('savedClassId');
//   final savedMemberId = prefs.getString('savedMemberId');
//   final savedClassName = prefs.getString('savedClassName');

//   Widget firstPage;
//   if (savedClassId != null && savedMemberId != null && savedClassName != null) {
//     final classInfo = ClassModel(id: savedClassId, name: savedClassName);
//     firstPage = Home(classInfo: classInfo, currentMemberId: savedMemberId);
//   } else {
//     firstPage = const ClassSelectionPage();
//   }

//   runApp(MyApp(firstPage: firstPage));
// }

// class MyApp extends StatelessWidget {
//   final Widget firstPage;
//   const MyApp({Key? key, required this.firstPage}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => MyProfileModel()),
//         ChangeNotifierProvider(create: (_) => SettingProfileModel()),
//         ChangeNotifierProvider(create: (_) => MembersProfileModel()),
//         ChangeNotifierProvider(create: (_) => MessageModel()),
//         ChangeNotifierProvider(create: (_) => RankingPageModel()),
//       ],
//       child: MaterialApp(
//         title: 'Sotsu Bun',
//         navigatorKey: navigatorKey, // ここでグローバルキーを設定
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           primaryColor: darkBlueColor,
//           appBarTheme: const AppBarTheme(foregroundColor: blackColor),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: darkBlueColor,
//               foregroundColor: Colors.white,
//               textStyle: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//         ),
//         home: firstPage,
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/color.dart';
import 'package:school_memories2/pages/members_profile_model.dart';
import 'package:school_memories2/pages/message.dart';
import 'package:school_memories2/pages/myprofile_model.dart';
import 'package:school_memories2/pages/ranking_page_model.dart';
import 'package:school_memories2/pages/setting_profile.dart';
import 'package:school_memories2/signup/class_selection_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../class_model.dart';
import '../pages/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase初期化に失敗した場合は、エラーメッセージを表示するシンプルなUIを起動する
    runApp(MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('エラー')),
        body: Center(
          child: Text(
            'Firebaseの初期化に失敗しました。\nエラー: $e',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ));
    return;
  }

  // Firebase初期化成功後の処理
  final prefs = await SharedPreferences.getInstance();
  final savedClassId = prefs.getString('savedClassId');
  final savedMemberId = prefs.getString('savedMemberId');
  final savedClassName = prefs.getString('savedClassName');

  Widget firstPage;

  if (savedClassId != null && savedMemberId != null && savedClassName != null) {
    final classInfo = ClassModel(
      id: savedClassId,
      name: savedClassName,
    );
    firstPage = Home(
      classInfo: classInfo,
      currentMemberId: savedMemberId,
    );
  } else {
    firstPage = const ClassSelectionPage();
  }

  runApp(MyApp(firstPage: firstPage));
}


class MyApp extends StatelessWidget {
  final Widget firstPage;
  const MyApp({super.key, required this.firstPage});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyProfileModel()),
        ChangeNotifierProvider(create: (_) => SettingProfileModel()),
        ChangeNotifierProvider(create: (_) => MembersProfileModel()),
        ChangeNotifierProvider(create: (_) => MessageModel()),
        ChangeNotifierProvider(create: (_) => RankingPageModel()),
      ],
      child: MaterialApp(
        title: 'Sotsu Bun',
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
        home: firstPage,
      ),
    );
  }
}