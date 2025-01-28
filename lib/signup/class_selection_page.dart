import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'select_account_page.dart';

class ClassSelectionPage extends StatefulWidget {
  const ClassSelectionPage({Key? key}) : super(key: key);

  @override
  State<ClassSelectionPage> createState() => _ClassSelectionPageState();
}

class _ClassSelectionPageState extends State<ClassSelectionPage> {
  bool isCreating = true; // true: クラス作成タブ, false: 既存クラス参加タブ

  // クラス作成用
  final classNameController = TextEditingController();
  final classIdForCreateController = TextEditingController();
  final classPasswordForCreateController = TextEditingController();
  List<TextEditingController> memberControllers = [];

  // クラス参加用
  final classIdForJoinController = TextEditingController();
  final classPasswordForJoinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('クラスを作成 or 参加'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // タブ切り替え
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => setState(() => isCreating = true),
                  child: Text(
                    'クラスを作成',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCreating ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => isCreating = false),
                  child: Text(
                    'クラスに参加',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: !isCreating ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            isCreating ? _buildCreateClassArea() : _buildJoinClassArea(),
          ],
        ),
      ),
    );
  }

  /// クラスを作成するUI
  Widget _buildCreateClassArea() {
    return Column(
      children: [
        TextField(
          controller: classNameController,
          decoration: const InputDecoration(labelText: 'クラス名'),
        ),
        TextField(
          controller: classIdForCreateController,
          decoration: const InputDecoration(labelText: 'クラスID（例: classA）'),
        ),
        TextField(
          controller: classPasswordForCreateController,
          decoration: const InputDecoration(labelText: 'クラスのパスワード'),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            setState(() {
              // 「クラスメイトを追加」を押すたびに1行ずつ名前入力欄を追加
              memberControllers.add(TextEditingController());
            });
          },
          child: const Text('クラスメイトを追加'),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: memberControllers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: TextField(
                controller: memberControllers[index],
                decoration: InputDecoration(
                  labelText: 'メンバー${index + 1}の名前',
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _createClass,
          child: const Text('クラスを作成'),
        ),
      ],
    );
  }

  /// 既存クラスに参加するUI
  Widget _buildJoinClassArea() {
    return Column(
      children: [
        TextField(
          controller: classIdForJoinController,
          decoration: const InputDecoration(labelText: 'クラスID'),
        ),
        TextField(
          controller: classPasswordForJoinController,
          decoration: const InputDecoration(labelText: 'クラスのパスワード'),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _joinClass,
          child: const Text('クラスに参加'),
        ),
      ],
    );
  }

  /// クラス作成
  Future<void> _createClass() async {
    final className = classNameController.text.trim();
    final classId = classIdForCreateController.text.trim();
    final password = classPasswordForCreateController.text.trim();

    if (className.isEmpty || classId.isEmpty || password.isEmpty) {
      _showMessage('未入力の項目があります');
      return;
    }

    final classRef = FirebaseFirestore.instance.collection('classes').doc(classId);

    // クラスドキュメントを作成
    await classRef.set({
      'id': classId,
      'name': className,
      'password': password,
      'createdAt': DateTime.now(),
    });

    // members サブコレクションへメンバーを一括登録
    for (final controller in memberControllers) {
      final memberName = controller.text.trim();
      if (memberName.isNotEmpty) {
        final memberDoc = classRef.collection('members').doc(); // メンバーID自動生成
        await memberDoc.set({
          'id': memberDoc.id,
          'name': memberName,
          // 初期パスワードを使う場合はここで保存可能 (例: 'pass': '0000')
        });
      }
    }

    _showMessage('クラス「$className」作成完了！');

    // アカウントを選択
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SelectAccountPage(classId: classId)),
    );
  }

  /// クラスに参加
  Future<void> _joinClass() async {
    final classId = classIdForJoinController.text.trim();
    final password = classPasswordForJoinController.text.trim();

    if (classId.isEmpty || password.isEmpty) {
      _showMessage('クラスIDとパスワードを入力してください');
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('classes')
        .doc(classId)
        .get();
    if (!doc.exists) {
      _showMessage('指定のクラスIDは存在しません');
      return;
    }
    final data = doc.data()!;
    if (data['password'] != password) {
      _showMessage('パスワードが違います');
      return;
    }

    // OK → 名前選択画面へ
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SelectAccountPage(classId: classId)),
    );
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
