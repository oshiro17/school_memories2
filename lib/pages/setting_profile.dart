import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/class_model.dart';

class SettingProfileModel extends ChangeNotifier {
  bool isLoading = false;

  /// Firestoreへプロフィールを保存する
  Future<void> saveProfile({
    required String callme,
  required String birthday,
  required String subject,
  required String hobby,
  required String skill,
  required String dream,
  required String recentEvent,
  required String schoolLife,
  required String achievement,
  required String strength,
  required String weakness,
  required String futurePlan,
  required String futureMessage,
  required String futureSelf,
  required String goal,
  required String classId,
  required String memberId,
  required int avatarIndex, // アバター番号/ 追加: アバター番号
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      // classes/{classId}/members/{memberId} を更新
      final memberData = {
       'callme': callme,
      'birthday': birthday,
      'subject': subject,
      'hobby': hobby,
      'skill': skill,
      'dream': dream,
      'recentEvent': recentEvent,
      'schoolLife': schoolLife,
      'achievement': achievement,
      'strength': strength,
      'weakness': weakness,
      'futurePlan': futurePlan,
      'futureMessage': futureMessage,
      'futureSelf': futureSelf,
      'goal': goal,
      'avatarIndex': avatarIndex,  // Firestoreに保存
      'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(memberId)
          .set(memberData, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
/// プロフィールの新規設定・編集ページ
class SettingProfilePage extends StatefulWidget {
  final ClassModel classInfo;
  final String currentMemberId;

  const SettingProfilePage({
    Key? key,
    required this.classInfo,
    required this.currentMemberId,
  }) : super(key: key);

  @override
  State<SettingProfilePage> createState() => _SettingProfilePageState();
}

class _SettingProfilePageState extends State<SettingProfilePage> {
  // 入力用コントローラー
   final TextEditingController nameController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController hobbyController = TextEditingController();
  final TextEditingController skillController = TextEditingController();
  final TextEditingController dreamController = TextEditingController();
  final TextEditingController recentEventController = TextEditingController();
  final TextEditingController schoolLifeController = TextEditingController();
  final TextEditingController achievementController = TextEditingController();
  final TextEditingController strengthController = TextEditingController();
  final TextEditingController weaknessController = TextEditingController();
  final TextEditingController futurePlanController = TextEditingController();
  final TextEditingController bodyVsMindController = TextEditingController();
  final TextEditingController lifeStoryController = TextEditingController();
  final TextEditingController friendshipValueController = TextEditingController();
  final TextEditingController futureMessageController = TextEditingController();
  final TextEditingController futureSelfController = TextEditingController();
  final TextEditingController goalController = TextEditingController();
  final TextEditingController futureDreamController = TextEditingController();
  /// 全アバター画像を列挙
  final List<String> avatarPaths = [
    'assets/j0.png',
    'assets/j1.png',
    'assets/j2.png',
    'assets/j3.png',
    'assets/j4.png',
    'assets/j5.png',
    'assets/j6.png',
    'assets/j7.png',
    'assets/j8.png',
    'assets/j9.png',
    'assets/j10.png',
    'assets/j11.png',
    'assets/j12.png',
    'assets/j13.png',
    'assets/j14.png',
    'assets/j15.png',
    'assets/j16.png',
    'assets/j17.png',
    'assets/j18.png',
    'assets/j19.png',
  ];

  // 選択中のアバターindex
  int selectedAvatarIndex = 0; // デフォルト 0
bool _validateInputs() {
  final fields = {
    '名前': nameController.text,
    '誕生日': birthdayController.text,
    '好きな教科': subjectController.text,
    '趣味': hobbyController.text,
    '特技': skillController.text,
    'なりたい職業': dreamController.text,
    '最近の事件': recentEventController.text,
    '学校生活': schoolLifeController.text,
    '偉業': achievementController.text,
    '長所': strengthController.text,
    '短所': weaknessController.text,
    '100万円の使い道': futurePlanController.text,
    '10年後の自分へメッセージ': futureMessageController.text,
    '10年後の自分': futureSelfController.text,
    '目標': goalController.text,
    '将来の夢': futureDreamController.text,
  };

  for (var entry in fields.entries) {
    //  _showErrorDialog(context,'sss');
    if (entry.value.trim().isEmpty) {
      _showErrorDialog(context, '「${entry.key}」を入力してください。');
      return false;
    }
  }
  return true;
}
  Widget _buildProfileField(String label, TextEditingController controller, int maxLength, {bool isLongText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: isLongText ? null : 1, // 長文の場合は `null` にする
        keyboardType: isLongText ? TextInputType.multiline : TextInputType.text,
        inputFormatters: [LengthLimitingTextInputFormatter(maxLength)], // 文字数制限
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          counterText: '${controller.text.length}/$maxLength', // 文字数カウンター表示
        ),
        onChanged: (text) {
          setState(() {}); // 入力時にカウンター更新
        },
      ),
    );
  }

  /// **カテゴリごとのセクション**
  Widget _buildSection(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    // SettingProfileModel
    final model = Provider.of<SettingProfileModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール設定'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
               const SizedBox(height: 20),

            // --- アバター選択UI ---
            const Text(
              'アバター画像を選択:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // GridView でアバター画像を並べる
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: avatarPaths.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,         // 4列
                mainAxisExtent: 80,        // 縦方向の1マスの高さ
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final path = avatarPaths[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAvatarIndex = index;
                    });
                  },
                  child: Stack(
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(path),
                        ),
                      ),
                      // 選択中の場合は "チェック" アイコン表示
                      if (selectedAvatarIndex == index)
                        const Positioned(
                          right: 0,
                          bottom: 0,
                          child: Icon(Icons.check_circle, color: Colors.blue),
                        ),
                    ],
                  ),
                );
              },
            ),
                // 名前や基本情報の入力
 _buildSection([
              _buildProfileField('名前', nameController, 20),
              _buildProfileField('誕生日', birthdayController, 10),
              _buildProfileField('好きな教科', subjectController, 30),
            ]),

            /// **趣味・特技・なりたい職業（最大50文字）**
            _buildSection([
              _buildProfileField('趣味', hobbyController, 50),
              _buildProfileField('特技', skillController, 50),
              _buildProfileField('なりたい職業', dreamController, 50),
            ]),

            /// **最近の出来事（長文対応 最大200文字）**
            _buildSection([
              _buildProfileField('最近の事件は？', recentEventController, 200, isLongText: true),
              _buildProfileField('学校生活どうだった？', schoolLifeController, 200, isLongText: true),
              _buildProfileField('学校生活で達成した一番の偉業は何ですか？', achievementController, 200, isLongText: true),
            ]),

            /// **長所・短所（最大100文字）**
            _buildSection([
              _buildProfileField('長所', strengthController, 100),
              _buildProfileField('短所', weaknessController, 100),
            ]),

            /// **未来のこと（長文対応 最大300文字）**
            _buildSection([
              _buildProfileField('100万円あったら何したい？', futurePlanController, 300, isLongText: true),
              _buildProfileField('30歳の肉体 vs 30歳の精神、どちらを選ぶ？', bodyVsMindController, 300, isLongText: true),
              _buildProfileField('あなたがこれまでどんな人生を歩んできたのか', lifeStoryController, 300, isLongText: true),
              _buildProfileField('友情において最も価値のあることは何ですか？', friendshipValueController, 300, isLongText: true),
            ]),

            /// **10年後の自分（長文対応 最大250文字）**
            _buildSection([
              _buildProfileField('10年後の自分へメッセージ', futureMessageController, 250, isLongText: true),
              _buildProfileField('10年後何をしてる？', futureSelfController, 250, isLongText: true),
            ]),

            /// **目標（長文対応 最大250文字）**
            _buildSection([
              _buildProfileField('これからの目標', goalController, 250, isLongText: true),
              _buildProfileField('将来の夢は？', futureDreamController, 250, isLongText: true),
            ]),
            // --- 名前入力 ---
    
            const SizedBox(height: 15),

            // --- アバター選択UI ---


            // --- 保存ボタン ---
            Consumer<SettingProfileModel>(
  builder: (context, model, child) {
    return model.isLoading
        ? const Center(child: CircularProgressIndicator())
           : Center( // ✅ ここを追加
            child: ElevatedButton(
            onPressed: () async {
              if (!_validateInputs()) return; // バリデーションチェック

              try {
                await model.saveProfile(
                  callme: nameController.text,
                  birthday: birthdayController.text,
                  subject: subjectController.text,
                  hobby: hobbyController.text,
                  skill: skillController.text,
                  dream: dreamController.text,
                  recentEvent: recentEventController.text,
                  schoolLife: schoolLifeController.text,
                  achievement: achievementController.text,
                  strength: strengthController.text,
                  weakness: weaknessController.text,
                  futurePlan: futurePlanController.text,
                  futureMessage: futureMessageController.text,
                  futureSelf: futureSelfController.text,
                  goal: goalController.text,
                  classId: widget.classInfo.id,
                  memberId: widget.currentMemberId,
                  avatarIndex: selectedAvatarIndex,
                );

                Navigator.pop(context, true); // 成功時に戻る
              } catch (e) {
                _showErrorDialog(context, e.toString());
              }
            },
            child: const Text('保存'),
          ),);
  },
),
          ],
        ),
      ),
    );
  }

  Future<void> _showErrorDialog(BuildContext context, String message) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('エラー'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}
