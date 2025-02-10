import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/class_model.dart';
import 'package:school_memories2/color.dart';
import 'package:school_memories2/main.dart';
import 'package:school_memories2/pages/setting_profile_model.dart'; // navigatorKey が定義されているファイル

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
  final TextEditingController favoriteMovieController = TextEditingController();
  final TextEditingController favoritePersonController = TextEditingController();
  final TextEditingController favoriteTypeController = TextEditingController();
  final TextEditingController treasureController = TextEditingController();
  final TextEditingController thingController = TextEditingController();
  final TextEditingController wantController = TextEditingController();
  final TextEditingController favoritePlaceController = TextEditingController();
  final TextEditingController recentEventController = TextEditingController();
  final TextEditingController whatDidController = TextEditingController();
  final TextEditingController achievementController = TextEditingController();
  final TextEditingController strengthController = TextEditingController();
  final TextEditingController weaknessController = TextEditingController();
  final TextEditingController futurePlanController = TextEditingController();
  final TextEditingController lifeStoryController = TextEditingController();
  final TextEditingController futureSelfController = TextEditingController();
  final TextEditingController goalController = TextEditingController();
  final TextEditingController goalBigController = TextEditingController();
  final TextEditingController futureDreamController = TextEditingController();
  final TextEditingController mottoController = TextEditingController();

  final TextEditingController happyContoroller = TextEditingController();
  final TextEditingController hardController = TextEditingController();
  final TextEditingController funContoroller = TextEditingController();
  final TextEditingController cryContoroller = TextEditingController();

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
  // 選択中のアバター index（デフォルトは 5）
  int selectedAvatarIndex = 5;

  bool _validateInputs() {
    final fields = {
      '呼んでほしい名前': nameController.text,
      '何座?': birthdayController.text,
      '好きな教科、分野は?': subjectController.text,
      'あなたは一言で言うとどんな人？': bloodTypeController.text,
      '身長': heightController.text,
      'MBTI': mbtiController.text,
      '趣味・特技': hobbyController.text,
      '部活': clubController.text,
      'やりたい職業': dreamController.text,
      '好きな歌': favoriteSongController.text,
      '好きな映画': favoriteMovieController.text,
      '好きな人はいる？': favoritePersonController.text,
      '好きなタイプは？': favoriteTypeController.text,
      'たからもの': treasureController.text,
      '最近ゲットした一番高いもの': thingController.text,
      '今一番欲しいもの': wantController.text,
      '好きな場所は': favoritePlaceController.text,
      '最近の事件': recentEventController.text,
      '最近の幸せだったこと': happyContoroller.text,
      '最近きつかったこと': hardController.text,
      '最近の面白かったこと': funContoroller.text,
      '最後に泣いちゃったこと': cryContoroller.text,
      'きのう、何した？': whatDidController.text,
      '今までに達成した一番の偉業は？': achievementController.text,
      '長所': strengthController.text,
      '短所': weaknessController.text,
      '1億円あったら何したい？': futurePlanController.text,
      '尊敬している人は誰？': lifeStoryController.text,
      '10年後自分は何をしてると思う？': futureSelfController.text,
      '明日の目標は？': goalController.text,
      '叶えたい夢は？': goalBigController.text,
      'みんなへメッセージ': futureDreamController.text,
      '座右の銘': mottoController.text,
    };

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
    String hintText = '', // プレースホルダー
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: isLongText ? null : 1,
        keyboardType:
            isLongText ? TextInputType.multiline : TextInputType.text,
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(
              r'[A-Za-z0-9\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF'
              r'\u3000\u3001\u3002'
              r'\uFF01\uFF1F'
              r'\uFF08\uFF09'
              r'\u300C\u300D\u300E\u300F'
              r'\u301C\uFF5E'
              r']+',
            ),
          ),
          LengthLimitingTextInputFormatter(maxLength)
        ],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          hintText: hintText,
          counterText: '${controller.text.length}/$maxLength',
          prefixIcon: IconButton(
            icon: const Icon(Icons.lock),
            onPressed: () {
              setState(() {
                controller.text = '内緒';
              });
            },
          ),
        ),
        onChanged: (text) {
          setState(() {});
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
    // Connectivity のストリームを直接利用（不要なマッピングを削除）
    // final connectivityStream = Connectivity().onConnectivityChanged;

    return StreamBuilder<ConnectivityResult>(
         stream: Connectivity().onConnectivityChanged.map(
                  (results) =>
                      results.isNotEmpty ? results.first : ConnectivityResult.none,
                ),
      initialData: ConnectivityResult.mobile, // 初期値をオンラインとする
      builder: (context, snapshot) {
        final connectivityResult = snapshot.data ?? ConnectivityResult.mobile;
        final offline = connectivityResult == ConnectivityResult.none;

        return Scaffold(
          appBar: AppBar(
            title: Text(offline ? 'オフラインです。' : 'プロフィール設定'),
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
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: avatarPaths.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisExtent: 80,
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
                const SizedBox(height: 20),
                const Text(
                  '秘密にしたいときは左の鍵マークを押してね！',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                _buildSection([
                  _buildProfileField('呼んでほしい名前', nameController, 10, hintText: '例: 〇〇くん'),
                  _buildProfileField('何座?', birthdayController, 10, hintText: '例: 獅子座'),
                  _buildProfileField('好きな教科、分野は?', subjectController, 10, hintText: '例: 数学, 英語, 理科'),
                  _buildProfileField('あなたは一言で言うとどんな人？', bloodTypeController, 10, hintText: '例: 寂しがりや'),
                  _buildProfileField('身長', heightController, 7, hintText: '例: 155cm'),
                  _buildProfileField('MBTI', mbtiController, 6, hintText: '例: INTJ, ENFP'),
                  _buildProfileField('趣味・特技', hobbyController, 15, hintText: '例: 読書, サッカー, ピアノ'),
                  _buildProfileField('部活', clubController, 8, hintText: '例: バスケ部, 吹奏楽部'),
                  _buildProfileField('やりたい職業', dreamController, 10, hintText: '例: エンジニア, 獣医さん'),
                  _buildProfileField('好きな歌', favoriteSongController, 20, hintText: '好きな歌の名前'),
                  _buildProfileField('好きな映画', favoriteMovieController, 20, hintText: '好きな映画'),
                  _buildProfileField('好きな人はいる？', favoritePersonController, 10, hintText: '例: いない'),
                  _buildProfileField('好きなタイプは？', favoriteTypeController, 15, hintText: '例: 可愛い人'),
                  _buildProfileField('たからもの', treasureController, 15, hintText: '例: 弟'),
                  _buildProfileField('最近ゲットした一番高いもの', thingController, 20, hintText: '例: 天体望遠鏡'),
                  _buildProfileField('今一番欲しいもの', wantController, 20, hintText: '例: オープンカー'),
                  _buildProfileField('好きな場所は', favoritePlaceController, 15, hintText: '例: 蛍のいる田んぼ'),
                  _buildProfileField('最近の事件', recentEventController, 30, isLongText: true, hintText: '例: 合唱コンクール金賞！'),
                  _buildProfileField('最近の幸せだったこと', happyContoroller, 30, isLongText: true, hintText: '例: おいしいラーメンを食べた'),
                  _buildProfileField('最近きつかったこと', hardController, 30, isLongText: true, hintText: '例: テストが難しかった'),
                  _buildProfileField('最近の面白かったこと', funContoroller, 30, isLongText: true, hintText: '例: お笑いライブを見た'),
                  _buildProfileField('最後に泣いちゃったこと', cryContoroller, 30, isLongText: true, hintText: '例: 映画を見て'),
                  _buildProfileField('きのう、何した？', whatDidController, 30, isLongText: true, hintText: '例: お父さんとつり'),
                  _buildProfileField('今までに達成した一番の偉業は？', achievementController, 100, isLongText: true, hintText: '例: 全校生徒の前でスピーチをした'),
                  _buildProfileField('長所', strengthController, 20, hintText: '例: 人見知りせずに話せる'),
                  _buildProfileField('短所', weaknessController, 20, hintText: '例: マイペース'),
                  _buildProfileField('1億円あったら何したい？', futurePlanController, 30, isLongText: true, hintText: '例: キャンピングカーでアメリカ横断'),
                  _buildProfileField('尊敬している人は誰？', lifeStoryController, 15, hintText: '例: 父'),
                  _buildProfileField('10年後自分は何をしてると思う？', futureSelfController, 40, isLongText: true, hintText: '例: 結婚して子供が４人いて・・'),
                  _buildProfileField('明日の目標は？', goalController, 20, hintText: '例: 仲直り'),
                  _buildProfileField('叶えたい夢は？', goalBigController, 200, isLongText: true, hintText: '例: 大学へ行って、獣医さんになって‥'),
                  _buildProfileField('みんなへメッセージ', futureDreamController, 30, isLongText: true, hintText: '例: みんなと過ごせて楽しかったこれからもよろしく！'),
                  _buildProfileField('座右の銘', mottoController, 20, isLongText: true, hintText: '例: 継続は力なり'),
                ]),
                const SizedBox(height: 15),
                // --- 保存ボタン ---
                Consumer<SettingProfileModel>(
                  builder: (context, model, child) {
                    return model.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Center(
                            child: ElevatedButton(
                              // オフラインの場合は onPressed を null にして無効化
                              onPressed: offline
                                  ? null
                                  : () async {
                                      if (!_validateInputs()) return;
                                      bool? confirm = await _showConfirmationDialog(context);
                                      if (confirm != true) return;
                                      try {
                                        await model.saveProfile(
                                          q1: nameController.text,
                                          q2: birthdayController.text,
                                          q3: subjectController.text,
                                          q4: bloodTypeController.text,
                                          q5: heightController.text,
                                          q6: mbtiController.text,
                                          q7: hobbyController.text,
                                          q8: clubController.text,
                                          q9: dreamController.text,
                                          q10: favoriteSongController.text,
                                          q11: favoriteMovieController.text,
                                          q12: favoritePersonController.text,
                                          q13: favoriteTypeController.text,
                                          q14: treasureController.text,
                                          q15: thingController.text,
                                          q16: wantController.text,
                                          q17: favoritePlaceController.text,
                                          q18: recentEventController.text,
                                          q19: whatDidController.text,
                                          q20: achievementController.text,
                                          q21: strengthController.text,
                                          q22: weaknessController.text,
                                          q23: futurePlanController.text,
                                          q24: lifeStoryController.text,
                                          q25: futureSelfController.text,
                                          q26: goalController.text,
                                          q27: goalBigController.text,
                                          q28: futureDreamController.text,
                                          q29: mottoController.text,
                                          q30: happyContoroller.text,
                                          q31: hardController.text,
                                          q32: funContoroller.text,
                                          q33: cryContoroller.text,
                                          classId: widget.classInfo.id,
                                          memberId: widget.currentMemberId,
                                          avatarIndex: selectedAvatarIndex,
                                        );
                                        Navigator.pop(context, true);
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
      },
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
    favoriteMovieController.dispose();
    favoritePersonController.dispose();
    favoriteTypeController.dispose();
    treasureController.dispose();
    thingController.dispose();
    wantController.dispose();
    favoritePlaceController.dispose();
    recentEventController.dispose();
    whatDidController.dispose();
    achievementController.dispose();
    strengthController.dispose();
    weaknessController.dispose();
    futurePlanController.dispose();
    lifeStoryController.dispose();
    futureSelfController.dispose();
    goalController.dispose();
    goalBigController.dispose();
    futureDreamController.dispose();
    mottoController.dispose();
    happyContoroller.dispose();
    hardController.dispose();
    funContoroller.dispose();
    cryContoroller.dispose();
    super.dispose();
  }
}
