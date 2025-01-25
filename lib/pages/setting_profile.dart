import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class SettingProfileModel extends ChangeNotifier {
  bool isLoading = false;

  /// Firestoreへプロフィールを保存する
  Future<void> saveProfile({
    required String name,
    required String birthday,
    required String subject,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception('ログイン情報がありません。');
      }

      // Firestoreに保存するデータ
      final data = {
        'name': name,
        'birthday': birthday,
        'subject': subject,
        // 必要に応じて他のフィールドを追加
      };

      // Firestoreを更新（users/{uid}ドキュメント）
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(data, SetOptions(merge: true));

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
                        onPressed: () async {
                          try {
                            await model.saveProfile(
                              name: nameController.text,
                              birthday: birthdayController.text,
                              subject: subjectController.text,
                            );
                            Navigator.pop(context); // 設定画面を閉じる
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
