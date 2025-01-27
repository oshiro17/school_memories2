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
      create: (_) => WriteMessagePageProvider()..initData(classInfo.id),
      child: Scaffold(
        appBar: AppBar(title: Text('未送信のメンバーへメッセージ')),
        body: Consumer<WriteMessagePageProvider>(
          builder: (context, model, child) {
            if (model.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (model.notSentMembers.isEmpty) {
              return const Center(
                child: Text('全員に送信済みです！'),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: model.notSentMembers.length,
                    itemBuilder: (context, index) {
                      final member = model.notSentMembers[index];
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
                      await model.sendAllMessages(classInfo.id);
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

  // 「クラスの全メンバー」
  List<SelectPeopleModel> allMembers = [];
  // 「まだ送信していないメンバー」
  List<SelectPeopleModel> notSentMembers = [];
  // メンバーごとの入力欄
  List<TextEditingController> messageControllers = [];

  Future<void> initData(String classId) async {
    isLoading = true;
    notifyListeners();

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw 'ログインしていません。';
      }

      // クラスの全メンバーを取得
      final memberSnap = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .get();
      final members = memberSnap.docs.map((doc) {
        return SelectPeopleModel.fromMap(doc.data());
      }).toList();

      allMembers = members;

      // 自分が既に送信したメンバーID一覧を取得
      final sentSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('sentList')
          .where('classId', isEqualTo: classId) // このクラス向けの送信履歴
          .get();

      final sentMemberIds = sentSnap.docs.map((doc) => doc.id).toSet();

      // 送信していないメンバーだけフィルター
      notSentMembers = allMembers
          .where((m) => !sentMemberIds.contains(m.id))
          .toList();

      // テキストコントローラをメンバー数分用意
      messageControllers = List.generate(
        notSentMembers.length,
        (_) => TextEditingController(),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// メッセージ送信 & 送信履歴を登録
  Future<void> sendAllMessages(String classId) async {
    if (notSentMembers.isEmpty) {
      return; // 送信対象なし
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw 'ログインしていません。';
    }

    isLoading = true;
    notifyListeners();

    try {
      final senderDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final senderName = senderDoc.data()?['name'] ?? 'Unknown';

      for (int i = 0; i < notSentMembers.length; i++) {
        final member = notSentMembers[i];
        final message = messageControllers[i].text.trim();
        if (message.isEmpty) {
          continue; // 空文字なら送信しない
        }

        // 相手のusers/{member.id}/messages に書き込み
        await FirebaseFirestore.instance
            .collection('users')
            .doc(member.id)
            .collection('messages')
            .add({
          'message': message,
          'senderId': currentUser.uid,
          'senderName': senderName,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // 自分のsentList に登録 -> 送信済みであることを記録
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('sentList')
            .doc(member.id) // docIdをmember.idとする
            .set({
          'classId': classId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // 送信が完了したので、再読み込みして更新
      await initData(classId);

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
