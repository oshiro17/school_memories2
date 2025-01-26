import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/class_model.dart';
import 'package:school_memories2/pages/myprofile_model.dart';
import 'package:school_memories2/pages/setting_profile.dart';

class MyProfilePage extends StatelessWidget {
  final ClassModel classInfo;

  MyProfilePage({required this.classInfo});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyProfileModel>(
      create: (context) => MyProfileModel()..init(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<MyProfileModel>(
          builder: (context, model, child) {
            if (model.isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (model.name.isEmpty) {
              // プロフィール未設定時の画面
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('まだプロフィールが設定されていません！'),
                    Text('早速設定しよう'),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingProfilePage(classInfo: classInfo),
                          ),
                        );
                        if (result == true) {
                          // プロフィール保存後にfetchProfileを再実行
                          await Provider.of<MyProfileModel>(context, listen: false).fetchProfile();
                        }
                      },
                      child: Text("設定する"),
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
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage("https://picsum.photos/200/300"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    alignment: Alignment.bottomLeft,
                    padding: EdgeInsets.all(20),
                    child: Text(
                      model.name,
                      style: TextStyle(
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? '未設定' : value,
              style: TextStyle(
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
