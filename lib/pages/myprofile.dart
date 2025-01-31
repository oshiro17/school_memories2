  import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/class_model.dart';
import 'package:school_memories2/color.dart';
import 'package:school_memories2/pages/members_profile_model.dart';
import 'package:school_memories2/pages/myprofile_model.dart';
import 'package:school_memories2/pages/setting_profile.dart';

/// ラベルと値を表示する共通Widget
  Widget _buildProfileItem2(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),

  
        Expanded(
          child:  Text(
          '$value',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        ),

      ],
    );
  }
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
 Widget _buildProfileField(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkBlueColor),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }

Widget _buildSection(List<Widget> children) {
  return Container(
    width: double.infinity, // 横幅いっぱいにする
    margin: EdgeInsets.symmetric(vertical: 10), // 横のマージンをなくす
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

Widget _buildProfileText(String label, String value, {bool isCallMe = false}) {
    return Text.rich(
      TextSpan(
        children: [
          if (!isCallMe) TextSpan(text: label, style: TextStyle(color: Colors.black,fontSize: 16)),
          TextSpan(text: value, style: TextStyle(color: darkBlueColor,fontSize: 17)), // 青色
          if (!isCallMe) TextSpan(text: ' だよ', style: TextStyle(color: Colors.black,fontSize: 16)),
          if (isCallMe) TextSpan(text: ' って呼んで！', style: TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

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
    // 上位(MultiProvider)で提供された同じ MyProfileModel のインスタンスを使う
    final model = context.watch<MyProfileModel>();


    if (model.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // あとは model を使ってUIを構築する
    final isProfileEmpty = model.callme.isEmpty;
    if (isProfileEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // 縦方向の中央揃え
    crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
              const SizedBox(height: 15),
              const Text('まだプロフィールが設定されていません'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingProfilePage(
                        classInfo: classInfo,
                        currentMemberId: currentMemberId,
                      ),
                    ),
                  );
                  if (result == true) {
                    print('保存後に再取得');
                    model.fetchProfileOnce(classInfo.id, currentMemberId);
                    final membersModel = context.read<MembersProfileModel>();
      await membersModel.fetchClassMembers(classInfo.id,currentMemberId);
                  }
                },
                child: const Text('設定する'),
              ),
            ],
          ),
        ),
      );
    }

            final avatarPath = 'assets/j${model.avatarIndex}.png';
    // プロフィールがある場合のUI
    return Scaffold(
      body: 
 SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   
Row(
  crossAxisAlignment: CrossAxisAlignment.end,
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Padding(
      padding: const EdgeInsets.only(top: 100.0, left: 8.0, right: 8.0),
      child: CircleAvatar(
        radius: 50,
        backgroundImage: AssetImage(avatarPath),
      ),
    ),
    const SizedBox(width: 16),
    Text(
      
      model.name,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    ),
  ],
),
                  const SizedBox(height: 16),
                  // プロフィール詳細
           Center(
  child: Column(
    mainAxisSize: MainAxisSize.min, // 必要な分だけ高さを確保
    crossAxisAlignment: CrossAxisAlignment.center, // 横方向の中央揃え
 children: [
  _buildProfileText('こんにちは ', model.name),
  _buildProfileText('', model.callme, isCallMe: true),
  _buildProfileText('生年月日は ', model.birthday),
  _buildProfileText('好きな教科は ', model.subject),
  _buildProfileText('血液型は ', model.bloodType),
  _buildProfileText('身長は今, ', model.height),
  _buildProfileText('MBTIは ', model.mbti),
],
  ),
),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection([
  _buildProfileField('趣味特技', model.hobby),
  _buildProfileField('部活', model.club),
  _buildProfileField('なりたい職業', model.dream),
  _buildProfileField('好きな歌', model.favoriteSong),
  _buildProfileField('好きな人', model.favoritePerson),
  _buildProfileField('たからもの', model.treasure),
]),

_buildSection([
  _buildProfileField('最近の事件は？', model.recentEvent),
  _buildProfileField('学校生活どうだった？', model.schoolLife),
  _buildProfileField('学校生活で達成した一番の偉業は？', model.achievement),
]),

_buildSection([
  _buildProfileField('長所', model.strength),
  _buildProfileField('短所', model.weakness),
]),

_buildSection([
  _buildProfileField('100万あったら何したい？', model.futurePlan),
  _buildProfileField('あなたがこれまでどんな人生を歩んできたのか、教えて下さい。', model.lifeStory),
]),

_buildSection([
  _buildProfileField('10年後自分は何してると思う？', model.futureSelf),
  _buildProfileField('10年後の自分へメッセージ', model.futureMessage),
]),

_buildSection([
  _buildProfileField('これからの目標', model.goal),
  _buildProfileField('将来の夢', model.futureDream),
  _buildProfileField('座右の銘', model.motto),
]),


        
        const SizedBox(height: 32),
                        Center(
                          child: ElevatedButton(
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
                                                        await model.fetchProfileOnce(classInfo.id, currentMemberId);
                              }
                            },
                            child: const Text('プロフィールを編集'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
 ),
            );
    
  }
}
