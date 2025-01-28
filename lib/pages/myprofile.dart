import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/class_model.dart';
import 'package:school_memories2/pages/setting_profile.dart';

import 'myprofile_model.dart';

class MyProfilePage extends StatelessWidget {
  final ClassModel classInfo;
  final String currentMemberId;

  const MyProfilePage({
    required this.classInfo,
    required this.currentMemberId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyProfileModel>(
      create: (context) => MyProfileModel()..init(classInfo.id, currentMemberId),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<MyProfileModel>(
          builder: (context, model, child) {
            if (model.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (model.subject.isEmpty) {
              // プロフィール未設定時の画面
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('まだプロフィールが設定されていません！'),
                    const Text('早速設定しよう'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
           Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingProfilePage(classInfo: classInfo, currentMemberId: currentMemberId),
              ),
            ); 
          },
                      child: const Text("設定する"),
                    ),
                  ],
                ),
              );
            }

            // プロフィール設定済み時の画面
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ヘッダー画像部分
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage("https://picsum.photos/200/300"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      model.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 4,
                            color: Colors.black38,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // プロフィール詳細情報
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildProfileItem('誕生日', model.birthday),
                        buildProfileItem('好きな教科', model.subject),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// プロフィール項目を表示する共通ウィジェット
  Widget buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? '未設定' : value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
