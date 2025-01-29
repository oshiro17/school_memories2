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
    required String bloodType,
    required String height,
    required String mbti,
    required String hobby,
    required String club,
    required String dream,
    required String favoriteSong,
    required String favoritePerson,
    required String treasure,
    required String recentEvent,
    required String schoolLife,
    required String achievement,
    required String strength,
    required String weakness,
    required String futurePlan,
    required String lifeStory,
    required String futureMessage,
    required String futureSelf,
    required String goal,
    required String futureDream,
    required String motto,
    required String classId,
    required String memberId,
    required int avatarIndex,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      // classes/{classId}/members/{memberId} を更新
      final memberData = {
        '名前': callme,
        '生年月日': birthday,
        '好きな教科': subject,
        '血液型': bloodType,
        '身長': height,
        'MBTI': mbti,
        '趣味・特技': hobby,
        '部活': club,
        'なりたい職業': dream,
        '好きな歌': favoriteSong,
        '好きな人': favoritePerson,
        'たからもの': treasure,
        '最近の事件': recentEvent,
        '学校生活': schoolLife,
        '学校生活で達成した一番の偉業は？': achievement,
        '長所': strength,
        '短所': weakness,
        '100万円あったら何したい？': futurePlan,
        '今までどんな人生だった？': lifeStory,
        '10年後の自分へメッセージ': futureMessage,
        '10年後自分は何をしてると思う？': futureSelf,
        '目標': goal,
        '将来の夢は？': futureDream,
        '座右の銘': motto,
        'avatarIndex': avatarIndex, // Firestoreに保存
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
  final TextEditingController bloodTypeController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController mbtiController = TextEditingController();
  final TextEditingController hobbyController = TextEditingController();
  final TextEditingController clubController = TextEditingController();
  final TextEditingController dreamController = TextEditingController();
  final TextEditingController favoriteSongController = TextEditingController();
  final TextEditingController favoritePersonController = TextEditingController();
  final TextEditingController treasureController = TextEditingController();
  final TextEditingController recentEventController = TextEditingController();
  final TextEditingController schoolLifeController = TextEditingController();
  final TextEditingController achievementController = TextEditingController();
  final TextEditingController strengthController = TextEditingController();
  final TextEditingController weaknessController = TextEditingController();
  final TextEditingController futurePlanController = TextEditingController();
  final TextEditingController lifeStoryController = TextEditingController();
  final TextEditingController futureMessageController = TextEditingController();
  final TextEditingController futureSelfController = TextEditingController();
  final TextEditingController goalController = TextEditingController();
  final TextEditingController futureDreamController = TextEditingController();
  final TextEditingController mottoController = TextEditingController();

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

  /// 入力バリデーション
  bool _validateInputs() {
    final fields = {
      '呼んでほしい名前': nameController.text,
      '生年月日': birthdayController.text,
      '好きな教科': subjectController.text,
      '血液型': bloodTypeController.text,
      '身長': heightController.text,
      'MBTI': mbtiController.text,
      '趣味・特技': hobbyController.text,
      '部活': clubController.text,
      'なりたい職業': dreamController.text,
      '好きな歌': favoriteSongController.text,
      '好きな人': favoritePersonController.text,
      'たからもの': treasureController.text,
      '最近の事件': recentEventController.text,
      '学校生活': schoolLifeController.text,
      '学校生活で達成した一番の偉業は？': achievementController.text,
      '長所': strengthController.text,
      '短所': weaknessController.text,
      '100万円あったら何したい？': futurePlanController.text,
      '今までどんな人生だった？': lifeStoryController.text,
      '10年後の自分へメッセージ': futureMessageController.text,
      '10年後自分は何をしてると思う？': futureSelfController.text,
      '目標': goalController.text,
      '将来の夢': futureDreamController.text,
      '座右の銘': mottoController.text,
    };

    // **デバッグログ**
    debugPrint("==== 入力チェック開始 ====");
    fields.forEach((key, value) {
      debugPrint("$key: '${value.trim()}' (length: ${value.trim().length})");
    });

    for (var entry in fields.entries) {
      if (entry.value.trim().isEmpty) {
        debugPrint("❌ エラー: ${entry.key} が未入力");
        _showErrorDialog(context, '「${entry.key}」を入力してください。');
        return false;
      }
    }

    debugPrint("✅ すべての入力が完了しています");
    return true;
  }

  /// 確認ダイアログを表示する関数
  Future<bool?> _showConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('確認'),
          content: const Text('本当にいいですか？保存後は編集できません。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // キャンセル
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true), // OK
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// プロフィールフィールドをビルドするウィジェット
  Widget _buildProfileField(
    String label,
    TextEditingController controller,
    int maxLength, {
    bool isLongText = false,
    String hintText = '', // プレースホルダーを追加
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: isLongText ? null : 1, // 長文の場合は `null` にする
        keyboardType:
            isLongText ? TextInputType.multiline : TextInputType.text,
        inputFormatters: [
          LengthLimitingTextInputFormatter(maxLength)
        ], // 文字数制限
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          hintText: hintText, // 例文を表示
          counterText: '${controller.text.length}/$maxLength', // 文字数カウンター表示
          prefixIcon: IconButton(
            icon: const Icon(Icons.lock), // 🔒 アイコンを設定
            onPressed: () {
              setState(() {
                controller.text = '内緒！'; // アイコンを押すと「内緒！」を自動入力
              });
            },
          ),
        ),
        onChanged: (text) {
          setState(() {}); // 入力時にカウンター更新
        },
      ),
    );
  }

  /// カテゴリごとのセクションをビルドするウィジェット
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
                crossAxisCount: 4, // 4列
                mainAxisExtent: 80, // 縦方向の1マスの高さ
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
                          child:
                              Icon(Icons.check_circle, color: Colors.blue),
                        ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
  Text('秘密にしたいときは左の鍵マークを押してね！', 
      style: TextStyle(fontSize: 12, color: Colors.grey),
    ),
            // プロフィール入力フィールド
            _buildSection([
              _buildProfileField('名前', nameController, 10,
                  hintText: '例: たっちゃん'),
              _buildProfileField('生年月日', birthdayController, 10,
                  hintText: '例: 2000年01月01日'),
              _buildProfileField('好きな教科', subjectController, 10,
                  hintText: '例: 数学, 英語, 理科'),
              _buildProfileField('血液型', bloodTypeController, 2,
                  hintText: '例: A, B, O, AB'),
              _buildProfileField('身長', heightController, 5,
                  hintText: '例: 170cm'),
              _buildProfileField('MBTI', mbtiController, 6,
                  hintText: '例: INTJ, ENFP'),

              /// **趣味・特技・なりたい職業（最大50文字）**
              _buildProfileField('趣味・特技', hobbyController, 15,
                  hintText: '例: 読書, サッカー, ピアノ'),
              _buildProfileField('部活', clubController, 10,
                  hintText: '例: バスケ部, 吹奏楽部'),
              _buildProfileField('なりたい職業', dreamController, 10,
                  hintText: '例: エンジニア, 医者, 先生'),
              _buildProfileField('好きな歌', favoriteSongController, 20,
                  hintText: '例: 小さな恋のうた'),
              _buildProfileField('好きな人', favoritePersonController, 10,
                  hintText: '例: クラスの○○さん'),
              _buildProfileField('たからもの', treasureController, 20,
                  hintText: '例: 祖父からもらった時計'),

              /// **最近の出来事（長文対応 最大200文字）**
              _buildProfileField('最近の事件は？', recentEventController, 120,
                  isLongText: true,
                  hintText: '例: 文化祭でクラスが優勝した！'),
              _buildProfileField('学校生活どうだった？', schoolLifeController, 120,
                  isLongText: true,
                  hintText: '例: 部活で新記録を出せた！'),
              _buildProfileField(
                  '学校生活で達成した一番の偉業は？',
                  achievementController,
                  200,
                  isLongText: true,
                  hintText: '例: 全校生徒の前でスピーチをした'),

              /// **長所・短所（最大100文字）**
              _buildProfileField('長所', strengthController, 30,
                  hintText: '例: 人見知りせずに話せる'),
              _buildProfileField('短所', weaknessController, 30,
                  hintText: '例: 集中力が続かない'),

              /// **未来のこと（長文対応 最大300文字）**
              _buildProfileField('100万円あったら何したい？', futurePlanController, 40,
                  isLongText: true,
                  hintText: '例: ペットを飼いたい'),
              _buildProfileField('今までどんな人生だった？', lifeStoryController, 250,
                  isLongText: true, hintText: ''),

              /// **10年後の自分（長文対応 最大250文字）**
              _buildProfileField('10年後の自分へメッセージ',
                  futureMessageController, 250,
                  isLongText: true,
                  hintText: '例: 夢を諦めずに頑張ってるか？'),
              _buildProfileField(
                  '10年後自分は何をしてると思う？',
                  futureSelfController,
                  100,
                  isLongText: true,
                  hintText: '例: 結婚してる！'),

              /// **目標（長文対応 最大250文字）**
              _buildProfileField('これからの目標', goalController, 450,
                  isLongText: true,
                  hintText: ''),
              _buildProfileField('将来の夢は？', futureDreamController, 450,
                  isLongText: true,
                  hintText: ''),
              _buildProfileField('座右の銘', mottoController, 40,
                  isLongText: true, hintText: '例: 継続は力なり'),
            ]),

            const SizedBox(height: 15),

            // --- 保存ボタン ---
            Consumer<SettingProfileModel>(
              builder: (context, model, child) {
                return model.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!_validateInputs()) return; // バリデーションチェック

                            // 確認ダイアログを表示
                            bool? confirm =
                                await _showConfirmationDialog(context);
                            if (confirm != true) return; // キャンセルしたら処理を中断

                            try {
                              await model.saveProfile(
                                callme: nameController.text,
                                birthday: birthdayController.text,
                                subject: subjectController.text,
                                bloodType: bloodTypeController.text,
                                height: heightController.text,
                                mbti: mbtiController.text,
                                hobby: hobbyController.text,
                                club: clubController.text,
                                dream: dreamController.text,
                                favoriteSong: favoriteSongController.text,
                                favoritePerson:
                                    favoritePersonController.text,
                                treasure: treasureController.text,
                                recentEvent: recentEventController.text,
                                schoolLife: schoolLifeController.text,
                                achievement: achievementController.text,
                                strength: strengthController.text,
                                weakness: weaknessController.text,
                                futurePlan: futurePlanController.text,
                                lifeStory: lifeStoryController.text,
                                futureMessage: futureMessageController.text,
                                futureSelf: futureSelfController.text,
                                goal: goalController.text,
                                futureDream: futureDreamController.text,
                                motto: mottoController.text,
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
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// エラーダイアログを表示する関数
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

  @override
  void dispose() {
    // コントローラーの破棄
    nameController.dispose();
    birthdayController.dispose();
    subjectController.dispose();
    bloodTypeController.dispose();
    heightController.dispose();
    mbtiController.dispose();
    hobbyController.dispose();
    clubController.dispose();
    dreamController.dispose();
    favoriteSongController.dispose();
    favoritePersonController.dispose();
    treasureController.dispose();
    recentEventController.dispose();
    schoolLifeController.dispose();
    achievementController.dispose();
    strengthController.dispose();
    weaknessController.dispose();
    futurePlanController.dispose();
    lifeStoryController.dispose();
    futureMessageController.dispose();
    futureSelfController.dispose();
    goalController.dispose();
    futureDreamController.dispose();
    mottoController.dispose();
    super.dispose();
  }
}
