import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/color.dart';

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
    // Connectivity ストリーム（マッピング処理を削除）
    final connectivityStream = Connectivity().onConnectivityChanged;

    return StreamBuilder<ConnectivityResult>(
      // 初期データを適宜設定（例えば、初期は mobile とする）
      initialData: ConnectivityResult.mobile,
    stream: Connectivity().onConnectivityChanged.map(
        (results) => results.isNotEmpty ? results.first : ConnectivityResult.none,
      ),
      builder: (context, snapshot) {
        // snapshot.data が null の場合は ConnectivityResult.none とする
        final connectivityResult = snapshot.data ?? ConnectivityResult.none;
        final offline = connectivityResult == ConnectivityResult.none;

        return ChangeNotifierProvider(
          create: (_) => WriteMessagePageModel()
            ..initialize(classId, currentMemberId),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('寄せ書き送信'),
              elevation: 5,
            ),
            body: Consumer<WriteMessagePageModel>(
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
                // プロフィール設定がまだの場合
                if (!model.isCallme) {
                  return const Center(
                    child: Text(
                      '先にプロフィール設定をしてください。',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  );
                }

                // 未送信の場合はメッセージ入力画面を表示
                return Column(
                  children: [
                    // リスト部分
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        itemCount: model.memberList.length,
                        itemBuilder: (context, index) {
                          final member = model.memberList[index];
                          // TextField 用の3種類のコントローラを取得
                          final likeController = model.likeControllers[index];
                          final requestController =
                              model.requestControllers[index];
                          final messageController =
                              model.messageControllers[index];

                          return _buildMessageCard(
                            member: member,
                            likeController: likeController,
                            requestController: requestController,
                            messageController: messageController,
                          );
                        },
                      ),
                    ),

                    // 送信ボタン
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: ElevatedButton.icon(
                        // オフラインの場合は onPressed を null にして無効化
                        onPressed: offline
                            ? null
                            : () async {
                                try {
                                  await model.sendMessages();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text('メッセージを送信しました！'),
                                  ));
                                  Navigator.pop(context);
                                } catch (e) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(e.toString()),
                                  ));
                                }
                              },
                        icon: const Icon(Icons.send),
                        label: const Text('送信'),
                        style: ElevatedButton.styleFrom(
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
        );
      },
    );
  }

  /// 宛先メンバーごとのメッセージ入力カード
  Widget _buildMessageCard({
    required Map<String, dynamic> member,
    required TextEditingController likeController,
    required TextEditingController requestController,
    required TextEditingController messageController,
  }) {
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
            // 宛先: ~の好きなところ, すごいところ
            Text(
              '${member['name']}の好きなところ,すごいところ',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: darkBlueColor,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: likeController,
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
                LengthLimitingTextInputFormatter(20),
              ],
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
            const SizedBox(height: 10),

            // 宛先: ~へのお願い事
            Text(
              '${member['name']}へのお願い事',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: darkBlueColor,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: requestController,
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
                LengthLimitingTextInputFormatter(20),
              ],
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
            const SizedBox(height: 10),

            // 宛先: ~への個別メッセージ
            Text(
              '${member['name']}へメッセージ',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: darkBlueColor,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: messageController,
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
                LengthLimitingTextInputFormatter(250),
              ],
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
            const SizedBox(height: 5),
            Text(
              '送信された内容は${member['name']}のみ読むことができます。',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: darkBlueColor,
              ),
            ),
             const SizedBox(height: 15),
        
          ],
        ),
      ),
    );
  }
}



class WriteMessagePageModel extends ChangeNotifier {
  bool isLoading = false;
  bool isSent = false;
  bool isCallme = false;
  late String classId;
  late String currentMemberId;

  List<Map<String, dynamic>> memberList = [];

  // 各メンバーに紐づく3種類のTextEditingControllerを用意
  List<TextEditingController> likeControllers = [];
  List<TextEditingController> requestControllers = [];
  List<TextEditingController> messageControllers = [];

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

      if (memberDoc.data()?['q1'] != null) {
        isCallme = true;
      } else {
        isCallme = false;
      }
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
            'avatarIndex': doc.data()['avatarIndex'] ?? 0,
          };
        }).toList();

        memberList = allMembers.where((m) => m['id'] != currentMemberId).toList();

        // 各メンバーの件数分だけTextEditingControllerを作成
        likeControllers = List.generate(memberList.length, (_) => TextEditingController());
        requestControllers = List.generate(memberList.length, (_) => TextEditingController());
        messageControllers = List.generate(memberList.length, (_) => TextEditingController());
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// メッセージを全員に送信
  Future<void> sendMessages() async {
    // 各コントローラーが未入力でないかチェック
    if (memberList.length < 30)
    {
    for (int i = 0; i < memberList.length; i++) {
      if (
          likeControllers[i].text.trim().isEmpty) {
        throw '好きなところすごいところのみ必須項目です。';
      }
    }
    }

    isLoading = true;
    notifyListeners();

    try {
      // 各メンバーへメッセージ送信
      for (int i = 0; i < memberList.length; i++) {
        final member = memberList[i];
        final likeText = likeControllers[i].text.trim();
        final requestText = requestControllers[i].text.trim();
        final personalText = messageControllers[i].text.trim();

        await FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .collection('members')
            .doc(member['id'])
            .collection('messages')
            .add({
          'senderId': currentMemberId,
          'likeMessage': likeText,
          'requestMessage': requestText,
          'message': personalText,
          'avatarIndex': avatarIndex, // 自分のアバター番号
          'senderName': senderName,   // 自分の名前
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
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        return;
      } else {
        throw 'Firebaseエラー: ${e.message}';
      }
    } catch (e) {
      throw 'エラー: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final controller in likeControllers) {
      controller.dispose();
    }
    for (final controller in requestControllers) {
      controller.dispose();
    }
    for (final controller in messageControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}