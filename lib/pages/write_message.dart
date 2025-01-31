import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class WriteMessagePage extends StatelessWidget {
  final String classId;
  final String currentMemberId;

  const WriteMessagePage({
    Key? key,
    required this.classId,
    required this.currentMemberId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WriteMessagePageModel()..initialize(classId, currentMemberId),
      child: Scaffold(
        // AppBarのデザイン変更例（お好みで調整してください）
        appBar: AppBar(
          title: const Text('寄せ書き送信'),
          // backgroundColor: Colors.brown,
          elevation: 5,
        ),
        // 背景を画像 or グラデーションなどお好みで
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/paper_texture.jpg'), // お好みの紙や背景画像
              fit: BoxFit.cover,
            ),
          ),
          child: Consumer<WriteMessagePageModel>(
            builder: (context, model, child) {
              // ローディング中
              if (model.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // 既に送信済み
              if (model.isSent) {
                return const Center(
                  child: Text(
                    '既にメッセージを送信しました。',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                );
              }

              return Column(
                children: [
                  // リスト部分
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      itemCount: model.memberList.length,
                      itemBuilder: (context, index) {
                        final member = model.memberList[index];
                        final controller = model.messageControllers[index];

                        return _buildMessageCard(member, controller);
                      },
                    ),
                  ),

                  // 送信ボタン
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await model.sendMessages();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('メッセージを送信しました！')),
                          );
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('送信'),
                      style: ElevatedButton.styleFrom(
                        // backgroundColor: Colors.brown, // ボタンの背景色
                        // foregroundColor: Colors.white,  // 文字とアイコンの色
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// 宛先メンバーごとのメッセージ入力カード
  Widget _buildMessageCard(Map<String, dynamic> member, TextEditingController controller) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 宛先: ~
            Text(
              '宛先: ${member['name']}',
              style: const TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 10),
            // メッセージ入力
            TextField(
               inputFormatters: [
    LengthLimitingTextInputFormatter(250), // 最大10文字に制限
  ],
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                fillColor: Colors.white,
                filled: true,
                hintText: 'メッセージを入力してください',
              ),
              maxLines: 3,
            ),
          ],
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
  String senderName = '';
  int avatarIndex = 0;

  /// 初期化
  Future<void> initialize(String classId, String currentMemberId) async {
    this.classId = classId;
    this.currentMemberId = currentMemberId;

    isLoading = true;
    notifyListeners();

    try {
      // 自分のドキュメントを取得
      final memberDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(currentMemberId)
          .get();

      isSent = memberDoc.data()?['isSent'] ?? false;
      senderName = memberDoc.data()?['name'] ?? 'Unknown';
      avatarIndex = memberDoc.data()?['avatarIndex'] ?? 0;

      // まだ送信していなければ、クラスメンバー一覧を取得
      if (!isSent) {
        final memberSnapshot = await FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .collection('members')
            .get();

        // 自分以外のメンバーをリスト化
        final allMembers = memberSnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc.data()['name'] ?? 'Unknown',
            'avatarIndex': doc.data()['avatarIndex'] ?? 0
          };
        }).toList();

        // "自分から自分へのメッセージ" を除外
        memberList = allMembers.where((m) => m['id'] != currentMemberId).toList();

        // メンバーの件数分だけTextEditingControllerを作る
        messageControllers =
            List.generate(memberList.length, (_) => TextEditingController());
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// メッセージを全員に送信
  Future<void> sendMessages() async {
    // 空メッセージがあるかチェック
    if (messageControllers.any((controller) => controller.text.trim().isEmpty)) {
      throw '全員にメッセージを入力してください。';
    }

    isLoading = true;
    notifyListeners();

    try {
      // 各メンバーへメッセージ送信
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
          'avatarIndex': avatarIndex,  // 自分のアバター番号
          'senderName': senderName,    // 自分の名前
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // 自分の isSent を更新
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
