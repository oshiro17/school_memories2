import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/class_model.dart';
import 'package:school_memories2/pages/myprofile_model.dart';
import 'package:school_memories2/pages/setting_profile.dart';

/// 自分のプロフィールを表示するページ
class MyProfilePage extends StatelessWidget {
  final ClassModel classInfo;
  final String currentMemberId;

  const MyProfilePage({
    Key? key,
    required this.classInfo,
    required this.currentMemberId,
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
              return const Center(child: CircularProgressIndicator());
            }

            // プロフィール未設定(例: subjectが空)の場合
            final isProfileEmpty = model.callme.isEmpty && model.subject.isEmpty && model.birthday.isEmpty;

            if (isProfileEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('まだプロフィールが設定されていません！'),
                    const Text('早速設定しよう'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingProfilePage(
                              classInfo: classInfo,
                              currentMemberId: currentMemberId,
                            ),
                          ),
                        );
                        if (result == true) {
                          // 保存後に再取得
                          await model.fetchProfile(classInfo.id, currentMemberId);
                        }
                      },
                      child: const Text("設定する"),
                    ),
                  ],
                ),
              );
            }

            // avatarIndex からアセットパスを作る（例: j0.png ~ j19.png）
            final avatarPath = 'assets/j${model.avatarIndex}.png';

            // プロフィール表示UI
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 上部画像など（適当に変更可）
                  Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.blueAccent,
                    child: Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage(avatarPath),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // プロフィール詳細
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileItem('名前は', model.callme,'です'),
                        const SizedBox(height: 8),
                        _buildProfileItem('誕生日は', model.birthday,'です'),
                        const SizedBox(height: 8),
                        _buildProfileItem('名前は', model.callme,'です'),
                        const SizedBox(height: 8),
                        _buildProfileItem('名前は', model.callme,'です'),
                        const SizedBox(height: 8),
                        _buildProfileItem('誕生日は', model.birthday,'です'),
                        const SizedBox(height: 8),
                        _buildProfileItem('名前は', model.callme,'です'),
                        const SizedBox(height: 8),
                        _buildProfileItem('誕生日は', model.birthday,'です'),
                        const SizedBox(height: 8),
                        _buildProfileItem('名前は', model.callme,'です'),
                        const SizedBox(height: 8),
                        _buildProfileItem('誕生日は', model.birthday,'です'),
                        const SizedBox(height: 8),
                        _buildProfileItem('誕生日は', model.birthday,'です'),
                        const SizedBox(height: 8),
                        _buildProfileItem('名前は', model.callme,'です'),
                        const SizedBox(height: 8),
                        _buildProfileItem('誕生日は', model.birthday,'です'),
                        const SizedBox(height: 8),
                        _buildProfileItem('名前は', model.callme,'です'),
                        const SizedBox(height: 8),
                        _buildProfileItem('誕生日は', model.birthday,'です'),
                        const SizedBox(height: 8),
                        _buildProfileItem('名前は', model.callme,'です'),
                        const SizedBox(height: 8),
                        _buildProfileItem('誕生日は', model.birthday,'です'),
                        const SizedBox(height: 8),
                        _buildProfileItem('名前は', model.callme,'です'),
                        const SizedBox(height: 8),
                        _buildProfileItem('誕生日は', model.birthday,'です'),
                        const SizedBox(height: 8),
                        _buildProfileItem('好きな教科は', model.subject,'です'),
                        // const SizedBox(height: 32),
                        // プロフィール編集ボタン
                        // Center(
                        //   child: ElevatedButton(
                        //     onPressed: () async {
                        //       final result = await Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (context) => SettingProfilePage(
                        //             classInfo: classInfo,
                        //             currentMemberId: currentMemberId,
                        //           ),
                        //         ),
                        //       );
                        //       if (result == true) {
                        //         // 保存後に再取得
                        //         await model.fetchProfile(classInfo.id, currentMemberId);
                        //       }
                        //     },
                        //     child: const Text('プロフィールを編集'),
                        //   ),
                        // ),
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

  /// ラベルと値を表示する共通Widget
  Widget _buildProfileItem(String label, String value, String label2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
          
         Text(
            value.isNotEmpty ? value : '未設定',
            style: const TextStyle(fontSize: 16, color: Colors.blue),

          ),
  
        Expanded(
          child:  Text(
          '$label2',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        ),

      ],
    );
  }
}
