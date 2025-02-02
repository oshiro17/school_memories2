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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
