import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class WriteMessagePage extends StatelessWidget {
  final String classId;
  final String currentMemberId;

  const WriteMessagePage({required this.classId, required this.currentMemberId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WriteMessagePageModel()..initialize(classId, currentMemberId),
      child: Scaffold(
        appBar: AppBar(title: Text('メッセージ送信')),
        body: Consumer<WriteMessagePageModel>(
          builder: (context, model, child) {
            if (model.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (model.isSent) {
              return Center(
                child: Text(
                  'このメンバーには既にメッセージを送信しました。',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: model.memberList.length,
                    itemBuilder: (context, index) {
                      final member = model.memberList[index];
                      final controller = model.messageControllers[index];
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '宛先: ${member['name']}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: controller,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'メッセージを入力してください',
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await model.sendMessages();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('メッセージを送信しました！')),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  child: Text('送信'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class WriteMessagePageModel extends ChangeNotifier {
  bool isLoading = false;
  bool isSent = false;
  List<Map<String, dynamic>> memberList = [];
  List<TextEditingController> messageControllers = [];
  late String classId;
  late String currentMemberId;

  void initialize(String classId, String currentMemberId) async {
    this.classId = classId;
    this.currentMemberId = currentMemberId;

    isLoading = true;
    notifyListeners();

    try {
      final memberDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(currentMemberId)
          .get();

      isSent = memberDoc.data()?['isSent'] ?? false;

      if (!isSent) {
        final memberSnapshot = await FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .collection('members')
            .get();

        memberList = memberSnapshot.docs.map((doc) {
          return {'id': doc.id, 'name': doc.data()['name'] ?? 'Unknown'};
        }).toList();

        messageControllers =
            List.generate(memberList.length, (_) => TextEditingController());
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessages() async {
    if (messageControllers.any((controller) => controller.text.trim().isEmpty)) {
      throw '全員にメッセージを入力してください。';
    }

    isLoading = true;
    notifyListeners();

    try {
      for (int i = 0; i < memberList.length; i++) {
        final member = memberList[i];
        final message = messageControllers[i].text.trim();

        await FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .collection('members')
            .doc(member['id'])
            .collection('messages')
            .add({
          'message': message,
          'senderId': currentMemberId,
          'senderName': 'Your Name', // 必要に応じて変更
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // メンバーの `isSent` を更新
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(currentMemberId)
          .update({'isSent': true});

      isSent = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final controller in messageControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
