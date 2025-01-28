import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/class_model.dart';
import 'package:school_memories2/pages/message.dart';
import 'package:school_memories2/pages/select_people_model.dart';
import 'write_message.dart';

enum ClassMemberAction { writeMessage, voteRanking }

class ClassMemberPage extends StatelessWidget {
  final ClassMemberAction action;
  final ClassModel classInfo;

  const ClassMemberPage({required this.action, required this.classInfo});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SelectPeopleModelProvider>(
      create: (_) => SelectPeopleModelProvider()..fetchMembers(classInfo.id),
      child: Scaffold(
        appBar: AppBar(title: const Text('クラスメイト一覧')),
        body: Consumer<SelectPeopleModelProvider>(
          builder: (context, model, child) {
            if (model.isLoading) {
              return const Center(child: CircularProgressIndicator());
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
                  onTap: () {
                    // if (action == ClassMemberAction.writeMessage) {
                    //   // メンバー情報を次画面へ渡す
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => WritingMessagePage(selectMember: member),
                    //     ),
                    //   );
                    // } else {
                      // 投票用ダイアログ
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
                                  Navigator.pop(context); // ダイアログを閉じる
                                  Navigator.pop(context, member); // 投票先を返す
                                },
                                child: const Text('投票する'),
                              ),
                            ],
                          );
                        },
                      );
                    // }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class SelectPeopleModelProvider extends ChangeNotifier {
  List<SelectPeopleModel> members = [];
  bool isLoading = false;

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

      members = snapshot.docs.map((doc) {
        final data = doc.data();
        return SelectPeopleModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('メンバー取得エラー: $e');
      members = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}