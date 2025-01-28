import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/signup/class_selection_page.dart';
import 'package:school_memories2/signup/class_selection_page_model.dart';
import 'class_list_page_model.dart';
import '../class_model.dart';
import '../pages/home.dart';

class ClassListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ClassListPageModel>(
      create: (_) => ClassListPageModel()..fetchAttendingClasses(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('参加クラス一覧'),
        ),
        body: Consumer<ClassListPageModel>(
          builder: (context, model, child) {
            if (model.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final classes = model.joinedClasses;
            if (classes.isEmpty) {
              return Center(
                child: Text('参加中のクラスはありません'),
              );
            }
            return ListView.builder(
              itemCount: classes.length,
              itemBuilder: (context, index) {
                final c = classes[index];
                return ListTile(
                  title: Text('${c.name} ( ${c.classNumber} )'),
                  onTap: () => _onTapClass(context, c),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            // 新しいクラスに参加・作成
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ClassSelectionPage()),
            );
          },
        ),
      ),
    );
  }

  Future<void> _onTapClass(BuildContext context, ClassModel classModel) async {
    // パスワード入力ダイアログを表示
    final passwordController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('クラスのパスワードを入力してください'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context)
                .pop(passwordController.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    // キャンセルまたは未入力なら何もしない
    if (result == null || result.isEmpty) {
      return;
    }

    // 照合
    try {
      await Provider.of<ClassListPageModel>(context, listen: false)
          .checkPasswordAndEnter(classModel, result);
      // パスワードが合っていたら HomePage へ
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Home(classInfo: classModel)),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('エラー'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            )
          ],
        ),
      );
    }
  }
}