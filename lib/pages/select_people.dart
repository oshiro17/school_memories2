import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/class_model.dart';
import 'package:school_memories2/pages/select_people_model.dart'; // Provider とモデルの定義があると仮定
import 'write_message.dart';

enum ClassMemberAction { writeMessage, voteRanking }

class ClassMemberPage extends StatelessWidget {
  final ClassMemberAction action;
  final ClassModel classInfo;

  const ClassMemberPage({
    Key? key,
    required this.action,
    required this.classInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Connectivity().onConnectivityChanged は List<ConnectivityResult> を返すので defensive に扱う
    final connectivityStream = Connectivity().onConnectivityChanged.map(
      (results) => results.isNotEmpty ? results.first : ConnectivityResult.none,
    );

    return StreamBuilder<ConnectivityResult>(
      stream: connectivityStream,
      builder: (context, snapshot) {
        // snapshot.data が null の場合は ConnectivityResult.none とする
        final connectivityResult = snapshot.data ?? ConnectivityResult.none;
        final offline = connectivityResult == ConnectivityResult.none;

        return ChangeNotifierProvider<SelectPeopleModelProvider>(
          create: (_) => SelectPeopleModelProvider()..fetchMembers(classInfo.id),
          child: Scaffold(
            appBar: AppBar(title: const Text('クラスメイト一覧')),
            body: Consumer<SelectPeopleModelProvider>(
              builder: (context, model, child) {
                if (model.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                // エラーがある場合はエラーメッセージと再試行ボタンを表示
                if (model.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          model.errorMessage!,
                          style: const TextStyle(fontSize: 16, color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            model.fetchMembers(classInfo.id);
                          },
                          child: const Text('再試行'),
                        ),
                      ],
                    ),
                  );
                }
                if (model.members.isEmpty) {
                  return const Center(child: Text('メンバーがいません。'));
                }
                return ListView.builder(
                  itemCount: model.members.length,
                  itemBuilder: (context, index) {
                    final member = model.members[index];
                    return ListTile(
                      title: Text(member.name),
                      // オフラインの場合は onTap を null にしてタップできなくする
                      onTap: offline
                          ? null
                          : () {
                              // 投票用ダイアログ（必要に応じてコメントアウト部分を切り替え）
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('投票'),
                                    content: Text('${member.name} に投票しますか？'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context), // キャンセル
                                        child: const Text('キャンセル'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, member); // 投票先を返す
                                        },
                                        child: const Text('投票する'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class SelectPeopleModelProvider extends ChangeNotifier {
  List<SelectPeopleModel> members = [];
  bool isLoading = false;
  String? errorMessage; // エラー状態を保持するフィールド

  /// クラスのメンバーリストを取得
  Future<void> fetchMembers(String classId) async {
    try {
      isLoading = true;
      errorMessage = null; // エラー状態をリセット
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .get();

      members = snapshot.docs.map((doc) {
        final data = doc.data();
        return SelectPeopleModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('メンバー取得エラー: $e');
      errorMessage = 'メンバーの取得に失敗しました: $e';
      members = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
