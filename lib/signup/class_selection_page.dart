import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'select_account_page.dart';

class ClassSelectionPage extends StatefulWidget {
  const ClassSelectionPage({Key? key}) : super(key: key);

  @override
  State<ClassSelectionPage> createState() => _ClassSelectionPageState();
}

class _ClassSelectionPageState extends State<ClassSelectionPage> {
  bool isCreating = true; // true: クラス作成, false: 既存クラス参加

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
        child: Column(
          children: [
            const SizedBox(height: 20),
            // タブ切り替え
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () => setState(() => isCreating = true),
                  child: Column(
                    children: [
                      const Text(
                        'クラスを作成',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (isCreating)
                        Container(
                          color: Colors.blue,
                          width: 60,
                          height: 2,
                          margin: const EdgeInsets.only(top: 4),
                        ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => setState(() => isCreating = false),
                  child: Column(
                    children: [
                      const Text(
                        'クラスに参加',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (!isCreating)
                        Container(
                          color: Colors.blue,
                          width: 60,
                          height: 2,
                          margin: const EdgeInsets.only(top: 4),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            isCreating ? _buildCreateClassArea() : _buildJoinClassArea(),
          ],
        ),
      ),
    );
  }

  /// 「クラスを作成」UI
  Widget _buildCreateClassArea() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // クラス名
          TextField(
            controller: classNameController,
            decoration: const InputDecoration(labelText: 'クラス名'),
          ),
          const SizedBox(height: 8),
          // ユニークなID
          TextField(
            controller: classIdForCreateController,
            decoration: const InputDecoration(labelText: 'クラスID（任意文字列）'),
          ),
          const SizedBox(height: 8),
          // パスワード
          TextField(
            controller: classPasswordForCreateController,
            decoration: const InputDecoration(labelText: 'クラスのパスワード'),
          ),
          const SizedBox(height: 16),
          // メンバー追加ボタン
          ElevatedButton(
            onPressed: () {
              setState(() {
                memberControllers.add(TextEditingController());
              });
            },
            child: const Text('クラスメイトを追加'),
          ),
          const SizedBox(height: 8),
          // メンバー入力欄一覧
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: memberControllers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: TextField(
                  controller: memberControllers[index],
                  decoration: InputDecoration(labelText: 'メンバー${index + 1}の名前'),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // クラス作成ボタン
          ElevatedButton(
            onPressed: () => _createClass(),
            child: const Text('クラスを作成'),
          ),
        ],
      ),
    );
  }

  /// 「クラスに参加」UI
  Widget _buildJoinClassArea() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: classIdForJoinController,
            decoration: const InputDecoration(labelText: 'クラスID'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: classPasswordForJoinController,
            decoration: const InputDecoration(labelText: 'クラスのパスワード'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _joinClass(),
            child: const Text('クラスに参加'),
          ),
        ],
      ),
    );
  }

  /// クラスを新規作成し、members サブコレクションに登録
  Future<void> _createClass() async {
    final className = classNameController.text.trim();
    final classId = classIdForCreateController.text.trim();
    final password = classPasswordForCreateController.text.trim();

    if (className.isEmpty || classId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('必要項目を入力してください。')),
      );
      return;
    }

    // Firestore書き込み
    final docRef = FirebaseFirestore.instance.collection('classes').doc(classId);
    final now = DateTime.now();

    // クラス自体を作成
    await docRef.set({
      'id': classId,
      'name': className,
      'password': password,
      'createdAt': now,
    });

    // メンバーを一括登録
    for (var controller in memberControllers) {
      final name = controller.text.trim();
      if (name.isNotEmpty) {
        final memberDoc = docRef.collection('members').doc(); // docIdは自動生成
        await memberDoc.set({
          'id': memberDoc.id, // メンバーID
          'name': name,
          // ここに初期パスワードを保存したい場合は
          // 'pass': '0000',
        });
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$className を作成しました。')),
    );

    // クラス作成後の動き
    // 例: 「あなたのアカウントを選択」画面へ → そこで自分の名前を選択させる
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectAccountPage(classId: classId),
      ),
    );
  }

  /// 既存クラスへ参加
  Future<void> _joinClass() async {
    final classId = classIdForJoinController.text.trim();
    final password = classPasswordForJoinController.text.trim();

    if (classId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('クラスID/パスワードを入力してください。')),
      );
      return;
    }

    // パスワードチェック
    final classDoc = await FirebaseFirestore.instance
        .collection('classes')
        .doc(classId)
        .get();

    if (!classDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('クラスが存在しません。')),
      );
      return;
    }

    final data = classDoc.data()!;
    if (data['password'] != password) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('パスワードが違います。')),
      );
      return;
    }

    // OK → 名前選択画面へ
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectAccountPage(classId: classId),
      ),
    );
  }

  @override
  void dispose() {
    classNameController.dispose();
    classIdForCreateController.dispose();
    classPasswordForCreateController.dispose();
    classIdForJoinController.dispose();
    classPasswordForJoinController.dispose();
    for (var c in memberControllers) {
      c.dispose();
    }
    super.dispose();
  }
}
