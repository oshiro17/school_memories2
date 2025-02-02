import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_memories2/signup/PrivacyPolicyPage.dart';
import 'package:school_memories2/signup/TermsOfServicePage.dart';
import '../color.dart';
import 'select_account_page.dart';

/// クラス作成ページ
class ClassSelectionPage extends StatefulWidget {
  const ClassSelectionPage({Key? key}) : super(key: key);

  @override
  State<ClassSelectionPage> createState() => _ClassSelectionPageState();
}

class _ClassSelectionPageState extends State<ClassSelectionPage> {
  bool isCreating = true; // true: クラス作成タブ, false: 既存クラス参加タブ

  // ローディング管理用 (画面全体)
  bool _isLoading = false;

  // クラス作成用
  final classNameController = TextEditingController();
  final classIdForCreateController = TextEditingController();
  final classPasswordForCreateController = TextEditingController();

  // ★ 初期からメンバー2名分のテキストフィールドを用意
  List<TextEditingController> memberControllers = [
    TextEditingController(), // メンバー1
    TextEditingController(), // メンバー2
  ];

  // クラス参加用
  final classIdForJoinController = TextEditingController();
  final classPasswordForJoinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
     'Sotsu Bun',
          style: GoogleFonts.dancingScript(
      fontSize: 24,
      color: darkBlueColor, // 文字色を青にする
    ),
  ),
      ),
      // Stackを使ってローディングを重ねて表示
      body: Stack(
        children: [
          // メインコンテンツ (スクロール領域)
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // タブ切り替え
                 SizedBox(height : 35),
                Text(
                        '卒業文集アプリへようこそ！',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: darkBlueColor,
                        ),
                      ),
                       SizedBox(height : 15),
                       Text(
                        'みんなの思い出を共有しましょう！',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:blackColor,
                        ),
                      ),
                      SizedBox(height : 35),
                        Text(
                        'クラスを作成、又は既存のクラスに参加してください',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color:  Colors.grey,
                        ),
                      ),
                      SizedBox(height : 30),

                Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Expanded(
      child: ElevatedButton(
        onPressed: () => setState(() => isCreating = true),
        style: ElevatedButton.styleFrom(
          backgroundColor: isCreating ?  darkBlueColor : Colors.white,
          foregroundColor: isCreating ? goldColor:  darkBlueColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.blue),
          ),
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          'クラスを作成',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ),
    const SizedBox(width: 10),
    Expanded(
      child: ElevatedButton(
        onPressed: () => setState(() => isCreating = false),
        style: ElevatedButton.styleFrom(
          backgroundColor: !isCreating ?  darkBlueColor : Colors.white,
          foregroundColor: !isCreating ?  goldColor:  darkBlueColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: darkBlueColor),
          ),
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          'クラスに参加',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ),
  ],
),

                const SizedBox(height: 16),
                // タブ切り替えでUI表示
                isCreating ? _buildCreateClassArea() : _buildJoinClassArea(),
              ],
            ),
          ),

          // ローディング表示 (_isLoading == true のときだけ表示)
          if (_isLoading)
            Container(
              color: Colors.black26, // 画面タップを防ぐ半透明の背景
              width: double.infinity,
              height: double.infinity,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  /// クラスを作成するUI
  /// クラスを作成するUI
Widget _buildCreateClassArea() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        controller: classNameController,
        decoration: const InputDecoration(labelText: 'クラス名'),
         inputFormatters: [
    LengthLimitingTextInputFormatter(10), // 最大10文字に制限
  ],
      ),
      TextField(
        controller: classIdForCreateController,
        decoration: const InputDecoration(labelText: 'クラスID（例: classA）'),
         inputFormatters: [
    LengthLimitingTextInputFormatter(10), // 最大10文字に制限
  ],
      ),
      TextField(
        controller: classPasswordForCreateController,
        decoration: const InputDecoration(labelText: 'クラスのパスワード'),
        obscureText: true,
 inputFormatters: [
    LengthLimitingTextInputFormatter(10), // 最大10文字に制限
  ],
      ),
      const SizedBox(height: 16),
      // メンバー入力欄リスト
      Column(
        children: [
          for (int i = 0; i < memberControllers.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: TextField(
                 inputFormatters: [
    LengthLimitingTextInputFormatter(10), // 最大10文字に制限
  ],
                controller: memberControllers[i],
                decoration: InputDecoration(
                  labelText: 'メンバー${i + 1}の名前',
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 16),

      // 「クラスメイトを追加」「クラスメイトを減らす」ボタン
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                memberControllers.add(TextEditingController());
              });
            },
            child: const Text('追加'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // 最低2人は残すようにする
                if (memberControllers.length > 2) {
                  memberControllers.removeLast();
                }
              });
            },
            child: const Text('消去'),
          ),
        ],
      ),
      const SizedBox(height: 19),


      // 同意文言とリンク追加
      _buildAgreementText(),

      const SizedBox(height: 19), 
      // "クラスを作成"ボタン
      Center(
        child:
      ElevatedButton(
        onPressed: _onPressCreateClass,
        child: const Text('クラスを作成'),
      ),),
    ],
  );
}
Widget _buildAgreementText() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: RichText(
      text: TextSpan(
        text: 'クラスを作成・参加することで、',
        style: const TextStyle(color: Colors.black),
        children: [
          TextSpan(
            text: 'プライバシーポリシー',
            style: const TextStyle(
              color: darkBlueColor,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
                );
              },
          ),
          const TextSpan(text: ' および '),
          TextSpan(
            text: '利用規約',
            style: const TextStyle(
              color: darkBlueColor,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TermsOfServicePage()),
                );
              },
          ),
          const TextSpan(text: ' に同意したことになります。'),
        ],
      ),
    ),
  );
}


  /// 既存クラスに参加するUI
  Widget _buildJoinClassArea() {
    return Column(
      children: [
       TextField(
  controller: classIdForJoinController,
  decoration: const InputDecoration(labelText: 'クラスID'),
  inputFormatters: [
    LengthLimitingTextInputFormatter(10), // 最大10文字に制限
  ],
),
  TextField(
  controller: classPasswordForJoinController,
  decoration: const InputDecoration(labelText: 'パスワード'),
  inputFormatters: [
    LengthLimitingTextInputFormatter(10), // 最大10文字に制限
  ],
),
        const SizedBox(height: 16),
              _buildAgreementText(),

      const SizedBox(height: 16),
ElevatedButton(
  onPressed: () async {
    await _joinClass(
      classIdForJoinController.text.trim(),
      classPasswordForJoinController.text.trim(),
      classNameController.text.trim(),
    );
  },
  child: const Text('クラスに参加'),
),

      ],
    );
  }

  /// 「クラスを作成」ボタン押下時の処理
  void _onPressCreateClass() {
    // バリデーションをここで行い、不備があれば終了
    final className = classNameController.text.trim();
    final classId = classIdForCreateController.text.trim();
    final password = classPasswordForCreateController.text.trim();
    final members = memberControllers
        .map((ctrl) => ctrl.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    // --- バリデーション ---
    if (className.isEmpty || classId.isEmpty || password.isEmpty) {
      _showMessage('未入力の項目があります');
      return;
    }
    if (members.length < 2) {
      _showMessage('メンバーは最低2人必要です');
      return;
    }
    // 名前の重複チェック
    final uniqueNames = members.toSet();
    if (uniqueNames.length != members.length) {
      _showMessage('名前が重複しています');
      return;
    }

    // ここでキーボードを閉じる
    FocusScope.of(context).unfocus();

    // すべてOKなら確認画面へ
    _showConfirmationPage(
      className: className,
      classId: classId,
      password: password,
      members: members,
    );
  }

  /// 確認画面を表示 (キーボードはすでに閉じている)
  void _showConfirmationPage({
    required String className,
    required String classId,
    required String password,
    required List<String> members,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmationPage(
          className: className,
          classId: classId,
          password: password,
          members: members,
          onConfirm: () => _joinClassAfterConfirm(className, classId, password, members),
        ),
      ),
    );
  }

  /// 確認画面から "進む" ボタンを押した時に呼ばれるメソッド
  /// ※ クラスを作成 → 参加フローを実現
  Future<void> _joinClassAfterConfirm(
    String className,
    String classId,
    String password,
    List<String> trimmedNames,
  ) async {
    if (_isLoading) return; // 二重押し防止

    // ローディング開始
    setState(() {
      _isLoading = true;
    });

    try {
      // Firestoreの参照
      final classRef = FirebaseFirestore.instance.collection('classes').doc(classId);

      // 1. クラスIDの重複確認
      final docSnap = await classRef.get();
      if (docSnap.exists) {
        _showMessage('クラスIDがもう使われています');
        return;
      }

      // --- クラス作成 ---
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

      // 成功時は遷移
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SelectAccountPage(classId: classId,className:className)),
        (route) => false,
      );
    } catch (e) {
      _showMessage('エラー: $e');
    } finally {
      // ローディング終了
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 既存クラスに参加
  Future<void> _joinClass(String classId, String password ,String className) async {
  if (_isLoading) return; // 二重押し防止

  // ローディング開始
  setState(() {
    _isLoading = true;
  });

  try {
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
    className = data['name'];

    // OK → アカウント選択画面へ
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SelectAccountPage(classId: classId, className: className)),
      (route) => false,
    );
  } catch (e) {
    _showMessage('エラー: $e');
  } finally {
    // ローディング終了
    setState(() {
      _isLoading = false;
    });
  }
}



  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

/// 確認画面（StatefulWidgetにして、overflow回避用にSingleChildScrollViewを使う）
class ConfirmationPage extends StatefulWidget {
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
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  // ここでローディングを管理してもOKだが、
  // 今回はメンバー倍増を防ぐため、親側で isLoading を管理し onConfirm 二重押しをブロックしています。
  // ここでは Overflow 対策 & UI 調整を中心に

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('確認'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('クラス名: ${widget.className}', style: const TextStyle(fontSize: 18)),
            Text('クラスID: ${widget.classId}', style: const TextStyle(fontSize: 18)),
            Text('パスワード: ${widget.password}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            const Text('メンバー:', style: TextStyle(fontSize: 18)),
            ...widget.members.map(
              (member) => Text(member, style: const TextStyle(fontSize: 16)),
            ),
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
                  child: const Text('編集'),
                ),
                // 「進む」ボタンを押すと 親の onConfirm() を呼ぶ
                ElevatedButton(
                  onPressed: widget.onConfirm,
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
