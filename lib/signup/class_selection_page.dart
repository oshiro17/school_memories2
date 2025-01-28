import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'select_account_page.dart';

/// クラス作成ページ
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
          onPressed: _showConfirmationPage,
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

  /// 確認画面を表示
  void _showConfirmationPage() {
    final className = classNameController.text.trim();
    final classId = classIdForCreateController.text.trim();
    final password = classPasswordForCreateController.text.trim();
    final members = memberControllers
        .map((controller) => controller.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    // バリデーション
    if (className.isEmpty || classId.isEmpty || password.isEmpty || members.isEmpty) {
      _showMessage('入力されていないところがあります');
      return;
    }
    if (members.length < 2) {
      _showMessage('メンバーは２人以上にしてください');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmationPage(
          className: className,
          classId: classId,
          password: password,
          members: members,
          onConfirm: _joinClassAfterConfirm,
        ),
      ),
    );
  }

  /// 確認画面から "進む" ボタンを押した時に呼ばれるメソッド
  /// ※ クラスを作成 → 参加フローを実現
  Future<void> _joinClassAfterConfirm() async {
    final className = classNameController.text.trim();
    final classId = classIdForCreateController.text.trim();
    final password = classPasswordForCreateController.text.trim();

    // Firestoreの参照
    final classRef = FirebaseFirestore.instance.collection('classes').doc(classId);

    try {
      // 1. クラスIDの重複確認
      final docSnap = await classRef.get();
      if (docSnap.exists) {
        _showMessage('クラスidがもう使われています');
        return;
      }

      // 2. メンバーの入力状態をチェック
      final trimmedNames = memberControllers.map((c) => c.text.trim()).toList();
      if (trimmedNames.any((name) => name.isEmpty)) {
        _showMessage('入力されていないところがあります');
        return;
      }

      // 3. メンバーが2人以上かどうか
      if (trimmedNames.length < 2) {
        _showMessage('メンバーは２人以上にしてください');
        return;
      }

      // 4. 名前重複チェック
      final uniqueNames = trimmedNames.toSet();
      if (uniqueNames.length != trimmedNames.length) {
        _showMessage('名前が被っています');
        return;
      }

      // 5. その他必須項目チェック
      if (className.isEmpty || classId.isEmpty || password.isEmpty) {
        _showMessage('未入力の項目があります');
        return;
      }

      // --- 上記のチェックを全てパスしたらクラス作成 ---
      await classRef.set({
        'id': classId,
        'name': className,
        'password': password,
        'createdAt': DateTime.now(),
      });

      // メンバー作成
      for (final name in trimmedNames) {
        final memberDoc = classRef.collection('members').doc();
        await memberDoc.set({
          'id': memberDoc.id,
          'name': name,
        });
      }

      _showMessage('クラス「$className」作成完了！');

      Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) =>SelectAccountPage(classId: classId)
      ),
      (route) => false, // すべての画面を削除
    );
    } catch (e) {
      _showMessage('エラー: $e');
    }
  }

  /// 既存クラスに参加
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
        Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) =>SelectAccountPage(classId: classId)
      ),
      (route) => false, // すべての画面を削除
    );
    // OK → 名前選択画面へ
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (_) => SelectAccountPage(classId: classId)),
    // );
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

/// 確認画面
class ConfirmationPage extends StatelessWidget {
  final String className;
  final String classId;
  final String password;
  final List<String> members;
  final VoidCallback onConfirm;

  const ConfirmationPage({
    Key? key,
    required this.className,
    required this.classId,
    required this.password,
    required this.members,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('確認'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('クラス名: $className', style: const TextStyle(fontSize: 18)),
            Text('クラスID: $classId', style: const TextStyle(fontSize: 18)),
            Text('パスワード: $password', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            const Text('メンバー:', style: TextStyle(fontSize: 18)),
            ...members.map((member) => Text(member, style: const TextStyle(fontSize: 16))),
            const SizedBox(height: 32),
            const Text(
              'クラス作成後は編集できません。よろしいですか？',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('もう一度編集'),
                ),
                ElevatedButton(
                  onPressed: onConfirm,
                  child: const Text('進む'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
