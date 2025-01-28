import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/class_model.dart';

class SettingProfileModel extends ChangeNotifier {
  bool isLoading = false;

  /// Firestoreへプロフィールを保存する
  Future<void> saveProfile({
    required String name,
    required String birthday,
    required String subject,
    required String classId, 
    required String memberId,
    // クラスIDを追加
  }) async {
    try {
      isLoading = true;
      notifyListeners();

   
      // classes/{classId}/members/{uid}を更新
      final memberData = {
        'subject': subject,
        'birthday': birthday,
        // 必要なら他のフィールドを追加
      };

      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(memberId)
          .set(memberData, SetOptions(merge: true));
    } catch (e) {
      // エラーハンドリング
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class SettingProfilePage extends StatelessWidget {
  final ClassModel classInfo;
  final String currentMemberId;
  SettingProfilePage({required this.classInfo,required this.currentMemberId});

  @override
  Widget build(BuildContext context) {
    // プロバイダーからモデルを取得
    final model = Provider.of<SettingProfileModel>(context, listen: false);

    // 入力用コントローラー
    final nameController = TextEditingController();
    final birthdayController = TextEditingController();
    final subjectController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('プロフィール設定'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: '名前'),
            ),
            TextField(
              controller: birthdayController,
              decoration: InputDecoration(labelText: '誕生日'),
            ),
            TextField(
              controller: subjectController,
              decoration: InputDecoration(labelText: '好きな教科'),
            ),
            const SizedBox(height: 20),
            Consumer<SettingProfileModel>(
              builder: (context, model, child) {
                return model.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                       // SettingProfilePageの保存ボタンの処理を修正
onPressed: () async {
  try {
    await model.saveProfile(
      name: nameController.text,
      birthday: birthdayController.text,
      subject: subjectController.text,
      classId: classInfo.id,
      memberId: currentMemberId,
       // クラスIDを渡す
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
