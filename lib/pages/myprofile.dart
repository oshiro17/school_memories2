import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/class_model.dart';
import 'package:school_memories2/color.dart';
import 'package:school_memories2/pages/members_profile_model.dart';
import 'package:school_memories2/pages/myprofile_model.dart';
import 'package:school_memories2/pages/setting_profile.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
        child: Text(
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
        child: Text(
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
          style:
              TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkBlueColor),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
      ],
    ),
  );
}

Widget _buildSection(List<Widget> children) {
  return Container(
    width: double.infinity, // 横幅いっぱいにする
    margin: const EdgeInsets.symmetric(vertical: 10), // 横のマージンをなくす
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 2),
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
        if (!isCallMe)
          TextSpan(
              text: label,
              style: const TextStyle(color: Colors.black, fontSize: 16)),
        TextSpan(
            text: value,
            style: const TextStyle(color: darkBlueColor, fontSize: 17)),
        if (!isCallMe)
          const TextSpan(
              text: ' だよ',
              style: TextStyle(color: Colors.black, fontSize: 16)),
        if (isCallMe)
          const TextSpan(
              text: ' って呼んで！',
              style: TextStyle(color: Colors.black)),
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

    if (model.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('エラーが発生しました'),
              ElevatedButton(
                onPressed: () {
                  model.fetchProfileOnce(classInfo.id, currentMemberId);
                },
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      );
    }
    if (model.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // プロフィールが未設定の場合
    final isProfileEmpty = model.q1.isEmpty;
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
              // オフラインの場合は「設定する」ボタンが押せないように StreamBuilder で制御
              StreamBuilder<ConnectivityResult>(
                stream: Connectivity().onConnectivityChanged.map(
                  (results) =>
                      results.isNotEmpty ? results.first : ConnectivityResult.none,
                ),
                builder: (context, snapshot) {
                  final connectivityResult =
                      snapshot.data ?? ConnectivityResult.mobile;
                  final offline = connectivityResult == ConnectivityResult.none;
                  return ElevatedButton(
                    onPressed: offline
                        ? null
                        : () async {
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
                              final membersModel =
                                  context.read<MembersProfileModel>();
                              await membersModel.fetchClassMembers(
                                  classInfo.id, currentMemberId);
                            }
                          },
                    child: const Text('設定する'),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    final avatarPath = 'assets/j${model.avatarIndex}.png';
    // プロフィールがある場合のUI
    return Scaffold(
      body: SingleChildScrollView(
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
                  style:
                      const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // プロフィール詳細
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfileText('こんにちは ', model.name),
                  _buildProfileText('', model.q1, isCallMe: true),
                  _buildProfileText('星座は', model.q2),
                  _buildProfileText('好きな教科は ', model.q3),
                  _buildProfileText('私を一言で表すと ', model.q4),
                  _buildProfileText('身長は今, ', model.q5),
                  _buildProfileText('MBTIは ', model.q6),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection([
                    _buildProfileField('趣味特技', model.q7),
                    _buildProfileField('部活', model.q8),
                    _buildProfileField('なりたい職業', model.q9),
                    _buildProfileField('好きな歌', model.q10),
                    _buildProfileField('好きな映画', model.q11),
                    _buildProfileField('好きな人', model.q12),
                    _buildProfileField('好きなタイプ', model.q13),
                    _buildProfileField('たからもの', model.q14),
                    _buildProfileField('最近ゲットした一番高いもの', model.q15),
                    _buildProfileField('今一番欲しいもの', model.q16),
                    _buildProfileField('好きな場所', model.q17),
                  ]),
                  _buildSection([
                    _buildProfileField('最近の事件は？', model.q18),
                    _buildProfileField('最近幸せだったこと', model.q30),
                    _buildProfileField('最近きつかったこと', model.q31),
                    _buildProfileField('最近面白かったこと', model.q32),
                    _buildProfileField('最近泣いちゃったこと', model.q33),
                    _buildProfileField('きのう、何した？', model.q19),
                    _buildProfileField('学校生活で達成した一番の偉業は？', model.q20),
                  ]),
                  _buildSection([
                    _buildProfileField('長所', model.q21),
                    _buildProfileField('短所', model.q22),
                  ]),
                  _buildSection([
                    _buildProfileField('1億円あったら何したい？', model.q23),
                    _buildProfileField('尊敬している人は誰？', model.q24),
                    _buildProfileField('10年後自分は何してると思う？', model.q25),
                    _buildProfileField('明日の目標は？', model.q26),
                    _buildProfileField('叶えたい夢は？', model.q27),
                  ]),
                  _buildSection([
                    _buildProfileField('みんなへメッセージ', model.q28),
                    _buildProfileField('座右の銘', model.q29),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
