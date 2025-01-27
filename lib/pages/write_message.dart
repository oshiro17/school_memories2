import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../class_model.dart';

class WriteMessagePage extends StatelessWidget {
  final ClassModel classInfo;

  const WriteMessagePage({
    Key? key,
    required this.classInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WriteMessagePageProvider>(
      create: (_) => WriteMessagePageProvider()..fetchMembers(classInfo.id),
      child: Scaffold(
        appBar: AppBar(title: const Text('メンバーごとに別メッセージを送信')),
        body: Consumer<WriteMessagePageProvider>(
          builder: (context, model, child) {
            if (model.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (model.members.isEmpty) {
              return const Center(child: Text('メンバーがいません。'));
            }

            return Column(
              children: [
                // メンバーごとのリスト表示
                Expanded(
                  child: ListView.builder(
                    itemCount: model.members.length,
                    itemBuilder: (context, index) {
                      final member = model.members[index];
                      final controller = model.messageControllers[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '相手: ${member.name}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: controller,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'ここにメッセージを入力してください',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // 送信ボタン
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await model.sendAllMessages();
                        // 送信完了時の通知
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('メッセージ送信が完了しました'),
                          ),
                        );
                      } catch (e) {
                        // エラー時ダイアログ
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('送信エラー'),
                            content: Text(e.toString()),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('閉じる'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: const Text('全員へ送信'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class WriteMessagePageProvider extends ChangeNotifier {
  bool isLoading = false;
  List<SelectPeopleModel> members = [];
  // メンバーごとに異なるメッセージを扱うためのController一覧
  List<TextEditingController> messageControllers = [];

  /// クラスのメンバーリストを取得
  Future<void> fetchMembers(String classId) async {
    try {
      isLoading = true;
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .get();

      final fetchedMembers = snapshot.docs.map((doc) {
        final data = doc.data();
        return SelectPeopleModel.fromMap(data);
      }).toList();

      members = fetchedMembers;

      // メンバー数と同じ数だけTextEditingControllerを用意
      messageControllers =
          List.generate(members.length, (_) => TextEditingController());
    } catch (e) {
      print('メンバー取得エラー: $e');
      members = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 全メンバー分のメッセージ送信処理
  Future<void> sendAllMessages() async {
    try {
      isLoading = true;
      notifyListeners();

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw 'ユーザーがログインしていません。';
      }
      final senderDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final senderName = senderDoc.data()?['name'] ?? 'Unknown';

      // 各メンバーにメッセージを送る
      for (int i = 0; i < members.length; i++) {
        final member = members[i];
        final text = messageControllers[i].text.trim();

        // 空文字の場合は送信しない
        if (text.isEmpty) {
          continue;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(member.id) // メンバーのID (SelectPeopleModel#id)
            .collection('messages')
            .add({
          'message': text,
          'senderId': currentUser.uid,
          'senderName': senderName,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // 送信後はコントローラーをクリア（任意）
      for (final controller in messageControllers) {
        controller.clear();
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // TextEditingControllerの破棄
    for (final controller in messageControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
