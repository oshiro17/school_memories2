import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/class_model.dart';

class SettingProfileModel extends ChangeNotifier {
  bool isLoading = false;

  /// Firestoreへプロフィールを保存する
  Future<void> saveProfile({
    required String callme,
    required String birthday,
    required String subject,
    required String classId,
    required String memberId,
    required int avatarIndex, // 追加: アバター番号
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      // classes/{classId}/members/{memberId} を更新
      final memberData = {
        'callme': callme,
        'birthday': birthday,
        'subject': subject,
        'avatarIndex': avatarIndex,  // Firestoreに保存
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
  final nameController = TextEditingController();
  final birthdayController = TextEditingController();
  final subjectController = TextEditingController();

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
            // --- 名前入力 ---
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '名前'),
            ),
            const SizedBox(height: 8),

            // --- 誕生日 ---
            TextField(
              controller: birthdayController,
              decoration: const InputDecoration(labelText: '誕生日'),
            ),
            const SizedBox(height: 8),

            // --- 好きな教科 ---
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: '好きな教科'),
            ),
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
            const SizedBox(height: 20),

            // --- 保存ボタン ---
            Consumer<SettingProfileModel>(
              builder: (context, model, child) {
                return model.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () async {
                          try {
                            await model.saveProfile(
                              callme: nameController.text,
                              birthday: birthdayController.text,
                              subject: subjectController.text,
                              classId: widget.classInfo.id,
                              memberId: widget.currentMemberId,
                              avatarIndex: selectedAvatarIndex, // 追加
                            );
                            Navigator.pop(context, true); // trueを返す
                          } catch (e) {
                            _showErrorDialog(context, e.toString());
                          }
                        },
                        child: const Text('保存'),
                      );
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
