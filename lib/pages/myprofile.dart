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
   // ...existing code...

Row(
  crossAxisAlignment: CrossAxisAlignment.end,
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Padding(
      padding: const EdgeInsets.only(top: 24.0, left: 8.0, right: 8.0),
      child: CircleAvatar(
        radius: 50,
        backgroundImage: AssetImage(avatarPath),
      ),
    ),
    const SizedBox(width: 16),
    Text(
      
      model.name,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          _buildProfileText('生年月日は ', model.callme),
          _buildProfileText('血液型は ', model.name),
          _buildProfileText('出身地は ', model.name),
          _buildProfileText('身長は今, ', model.name),
          _buildProfileText('MBTIは ', model.name),
    ],
  ),
),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         _buildSection([
            
           
              _buildProfileField('趣味', 'ピアノ, 海で泳ぐ, 旅行, 読書, 映画鑑賞, カメラ, 料理'),
              _buildProfileField('部活', 'ピアノ, 海で泳ぐ, 旅行, 読書, 映画鑑賞, カメラ, 料理'),
              _buildProfileField('特技', 'プログラミング, クワガタ飼育, 絵を描く, 楽器演奏, 速読, 手芸'),
              _buildProfileField('なりたい職業', 'エンジニア, デザイナー'),
              _buildProfileField('好きな歌', 'エンジニア, デザイナー'),
              _buildProfileField('出身地', '沖縄'),
              _buildProfileField('好きな人', '音楽, 旅行, ゲーム, カフェ巡り, ファッション, 動物, 自然'),
              _buildProfileField('たからもの', '音楽, 旅行, ゲーム, カフェ巡り, ファッション, 動物, 自然'),
            ]),
          _buildSection(
            [
              _buildProfileField('最近の事件は？', 'ピアノ, 海で泳ぐ, 旅行, 読書, 映画鑑賞skjdfksjhdfkjshdf泣かんん彼kねたくさん笑った赤かかかk, カメラ, 料理'),
              _buildProfileField('学校生活どうだった？', 'ピアノ, 海で泳ぐ, 旅行, 読書, 映画鑑賞skjdfksjhdfkjshdf泣かんん彼kねたくさん笑った赤かかかk, カメラ, 料理'),
              _buildProfileField('学校生活で達成した一番の偉業は何ですか？', 'ピアノ, 海で泳ぐ, 旅行, 読書, 映画鑑賞skjdfksjhdfkjshdf泣かんん彼kねたくさん笑った赤かかかk, カメラ, 料理'),
            ],
          ),
          _buildSection(
            [
              _buildProfileField('長所', 'ピアノ, 海で泳ぐ, 旅行, 読書, 映画鑑賞skjdfksjhdfkjshdf泣かんん彼kねたくさん笑った赤かかかk, カメラ, 料理'),
              _buildProfileField('短所は？', 'ピアノ, 海で泳ぐ, 旅行, 読書, 映画鑑賞skjdfksjhdfkjshdf泣かんん彼kねたくさん笑った赤かかかk, カメラ, 料理'),
            ],
          ),
          _buildSection(
            [
              _buildProfileField('100万あったら何したい？', 'ピアノ, 海で泳ぐ, 旅行, 読書, 映画鑑賞skjdfksjhdfkjshdf泣かんん彼kねたくさん笑った赤かかかk, カメラ, 料理'),
              _buildProfileField('あなたは90才まで生きることができ、最後の60年間を「30才の頃の肉体」か「30才の頃の精神」のどちらかを保つことができます。どちらを選びますか？', 'ピアノ, 海で泳ぐ, 旅行, 読書, 映画鑑賞skjdfksjhdfkjshdf泣かんん彼kねたくさん笑った赤かかかk, カメラ, 料理'),
              _buildProfileField('あなたがこれまでどんな人生を歩んできたのか、教えて下さい。', 'ピアノ, 海で泳ぐ, 旅行, 読書, 映画鑑賞skjdfksjhdfkjshdf泣かんん彼kねたくさん笑った赤かかかk, カメラ, 料理'),
              _buildProfileField('友情において最も価値のあることは何ですか？', 'ピアノ, 海で泳ぐ, 旅行, 読書, 映画鑑賞skjdfksjhdfkjshdf泣かんん彼kねたくさん笑った赤かかかk, カメラ, 料理'),
            ],
          ),
          _buildSection(
            [
              _buildProfileField('10年ご自分は何してると思う？', 'ピアノ, 海で泳ぐ, 旅行, 読書, 映画鑑賞skjdfksjhdfkjshdf泣かんん彼kねたくさん笑った赤かかかk, カメラ, 料理'),
              _buildProfileField('10年後の自分へメッセージ', 'ピアノ, 海で泳ぐ, 旅行, 読書, 映画鑑賞skjdfksjhdfkjshdf泣かんん彼kねたくさん笑った赤かかかk, カメラ, 料理'),
            ],
          ),
          _buildSection(
            [
              _buildProfileField('これからの目標', 'ピアノ, 海で泳ぐ, 旅行, 読書, 映画鑑賞skjdfksjhdfkjshdf泣かんん彼kねたくさん笑った赤かかかk, カメラ, 料理'),
              _buildProfileField('将来の夢は？', 'ピアノ, 海で泳ぐ, 旅行, 読書, 映画鑑賞skjdfksjhdfkjshdf泣かんん彼kねたくさん笑った赤かかかk, カメラ, 料理'),
            ],
          ),


        
        const SizedBox(height: 32),
                        // プロフィール編集ボタン
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
                                // 保存後に再取得
                                await model.fetchProfile(classInfo.id, currentMemberId);
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
            );
          },
        ),
      ),
    );
  }

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
}
 Widget _buildProfileField(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(List<Widget> children) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
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
          if (!isCallMe) TextSpan(text: label, style: TextStyle(color: Colors.black)),
          TextSpan(text: value, style: TextStyle(color: Colors.blue)), // 青色
          if (!isCallMe) TextSpan(text: ' だよ', style: TextStyle(color: Colors.black)),
          if (isCallMe) TextSpan(text: ' って呼んで！', style: TextStyle(color: Colors.black)),
        ],
      ),
    );
  }