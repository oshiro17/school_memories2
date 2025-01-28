import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/pages/message.dart';
import 'package:school_memories2/pages/select_people_model.dart';
import '../class_model.dart';

class WriteMessagePage extends StatelessWidget {
  final ClassModel classInfo;
  final String currentMemberId;

  const WriteMessagePage({
    Key? key,
    required this.classInfo,
    required this.currentMemberId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WriteMessagePageProvider>(
      create: (_) => WriteMessagePageProvider()..initData(classInfo.id),
      child: Scaffold(
        appBar: AppBar(title: Text('メンバーにメッセージを送る')),
        body: Consumer<WriteMessagePageProvider>(
          builder: (context, model, child) {
            if (model.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (model.allMembers.isEmpty) {
              return const Center(
                child: Text('メンバーがいません。'),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: model.allMembers.length,
                    itemBuilder: (context, index) {
                      final member = model.allMembers[index];
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
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await model.sendAllMessages(classInfo.id, currentMemberId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('送信が完了しました'),
                        ),
                      );
                    } catch (e) {
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
                  child: const Text('送信'),
                ),
                const SizedBox(height: 16),
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

  // クラスの全メンバー
  List<SelectPeopleModel> allMembers = [];
  // メンバーごとの入力欄
  List<TextEditingController> messageControllers = [];

  Future<void> initData(String classId) async {
    isLoading = true;
    notifyListeners();

    try {
      // クラスの全メンバーを取得
      final memberSnap = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .get();
      allMembers = memberSnap.docs.map((doc) {
        return SelectPeopleModel.fromMap(doc.data());
      }).toList();

      // テキストコントローラをメンバー数分用意
      messageControllers = List.generate(
        allMembers.length,
        (_) => TextEditingController(),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// メッセージ送信
  Future<void> sendAllMessages(String classId, String senderId) async {
    if (allMembers.isEmpty) {
      return; // 送信対象なし
    }

    isLoading = true;
    notifyListeners();

    try {
      final senderDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(senderId)
          .get();
      final senderName = senderDoc.data()?['name'] ?? 'Unknown';

      for (int i = 0; i < allMembers.length; i++) {
        final member = allMembers[i];
        final message = messageControllers[i].text.trim();
        if (message.isEmpty) {
          continue; // 空文字なら送信しない
        }

        // 相手のmessagesコレクションに書き込み
        await FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .collection('members')
            .doc(member.id)
            .collection('messages')
            .add({
          'message': message,
          'senderId': senderId,
          'senderName': senderName,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final c in messageControllers) {
      c.dispose();
    }
    super.dispose();
  }
}
