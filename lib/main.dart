import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/pages/setting_profile.dart';

import 'root_page.dart';
// import 'setting_profile_model.dart'; // モデルをインポート

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase初期化
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingProfileModel()), // SettingProfileModelを追加
      ],
      child: MaterialApp(
        title: 'School Memories',
        debugShowCheckedModeBanner: false,
        home: RootPage(),
      ),
    );
  }
}
