import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../color.dart';
import 'select_account_page.dart';


class ClassSelectionPage extends StatefulWidget {
  const ClassSelectionPage({Key? key}) : super(key: key);

  @override
  State<ClassSelectionPage> createState() => _ClassSelectionPageState();
}

class _ClassSelectionPageState extends State<ClassSelectionPage> {
  bool isCreating = true; // true: クラス作成タブ, false: 既存クラス参加タブ
  bool _isLoading = false; // 画面全体のローディング状態

  // クラス作成用
  final classNameController = TextEditingController();
  final classIdForCreateController = TextEditingController();
  final classPasswordForCreateController = TextEditingController();
  bool _obscureCreatePassword = true;

  // 初期からメンバー2名分のテキストフィールド
  List<TextEditingController> memberControllers = [
    TextEditingController(), // メンバー1
    TextEditingController(), // メンバー2
  ];

  // クラス参加用
  final classIdForJoinController = TextEditingController();
  final classPasswordForJoinController = TextEditingController();
  bool _obscureJoinPassword = true;

  /// パスワードのバリデーション（大文字、小文字、数字の組み合わせで6文字以上）
  bool _validatePassword(String password) {
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{6,}$');
    return regex.hasMatch(password);
  }

  /// クラス参加用パスワードを一時的に表示する（3秒後に非表示）
  void _showJoinPasswordTemporarily() {
    setState(() {
      _obscureJoinPassword = false;
    });
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _obscureJoinPassword = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sotsu Bun',
          style: GoogleFonts.dancingScript(
            fontSize: 24,
            color: darkBlueColor,
          ),
        ),
      ),
      // Stack を利用してローディングインジケータを重ねて表示
      body: Stack(
        children: [
          // メインコンテンツ（スクロール領域）
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 35),
                Text(
                  '卒業文集アプリへようこそ！',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: darkBlueColor,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'みんなの思い出を共有しましょう！',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: blackColor,
                  ),
                ),
                const SizedBox(height: 35),
                Text(
                  'クラスを作成、又は既存のクラスに参加してください',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() => isCreating = true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCreating ? darkBlueColor : Colors.white,
                          foregroundColor: isCreating ? goldColor : darkBlueColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Colors.blue),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
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
                          backgroundColor: !isCreating ? darkBlueColor : Colors.white,
                          foregroundColor: !isCreating ? goldColor : darkBlueColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: darkBlueColor),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'クラスに参加',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // タブ切り替えで表示
                isCreating ? _buildCreateClassArea() : _buildJoinClassArea(),
              ],
            ),
          ),
          // ローディング表示（_isLoading が true の場合）
          if (_isLoading)
            Container(
              color: Colors.black26,
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

  /// クラス作成用UI
  Widget _buildCreateClassArea() {
    return StreamBuilder<ConnectivityResult>(
      // 防御的記述を行い、リストが空の場合でも ConnectivityResult.none を返す
      stream: Connectivity().onConnectivityChanged.map(
        (results) => results.isNotEmpty ? results.first : ConnectivityResult.none,
      ),
      builder: (context, snapshot) {
        // snapshot.data が null ならオンラインと仮定する（もしくは適宜デフォルト設定）
        final connectivityResult = snapshot.data ?? ConnectivityResult.mobile;
        final offline = connectivityResult == ConnectivityResult.none;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: classNameController,
              decoration: const InputDecoration(labelText: 'クラス名'),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[A-Za-z0-9\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF@_\-]'),
                ),
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            TextField(
              controller: classIdForCreateController,
              decoration: const InputDecoration(labelText: 'クラスID（例: classA）'),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[A-Za-z0-9\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF@_\-]'),
                ),
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            TextField(
              controller: classPasswordForCreateController,
              decoration: InputDecoration(
                labelText: 'クラスのパスワード',
                helperText: '大文字、小文字、数字の組み合わせで6文字以上',
              ),
              obscureText: false,
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
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
                      controller: memberControllers[i],
                      decoration: InputDecoration(
                        labelText: 'メンバー${i + 1}の名前',
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[A-Za-z0-9\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF@_\-]'),
                        ),
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // 「追加」「消去」ボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: offline
                      ? null
                      : () {
                          setState(() {
                            memberControllers.add(TextEditingController());
                          });
                        },
                  child: const Text('追加'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: offline
                      ? null
                      : () {
                          setState(() {
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
            _buildAgreementText(),
            const SizedBox(height: 19),
            // 「クラスを作成」ボタン
            Center(
              child: ElevatedButton(
                onPressed: offline ? null : _onPressCreateClass,
                child: const Text('クラスを作成'),
              ),
            ),
          ],
        );
      },
    );
  }

 Future<void> _launchExternalURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    // エラー処理（必要に応じて）
    debugPrint('Could not launch $url');
  }
}

Widget _buildAgreementText() {
  return StreamBuilder<ConnectivityResult>(
    // Connectivity のストリームをそのまま利用
         stream: Connectivity().onConnectivityChanged.map(
        (results) => results.isNotEmpty ? results.first : ConnectivityResult.none,
      ),
    initialData: ConnectivityResult.mobile, // 初期状態はオンラインと仮定
    builder: (context, snapshot) {
      // snapshot.data が null の場合はオンライン（例: ConnectivityResult.mobile）と仮定
      final connectivityResult = snapshot.data ?? ConnectivityResult.mobile;
      final offline = connectivityResult == ConnectivityResult.none;

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
                recognizer: offline
                    ? null
                    : (TapGestureRecognizer()
                      ..onTap = () {
                        _launchExternalURL('https://note.com/nonokapiano/n/nede64e2d5743');
                      }),
              ),
              const TextSpan(text: ' および '),
              TextSpan(
                text: '利用規約',
                style: const TextStyle(
                  color: darkBlueColor,
                  decoration: TextDecoration.underline,
                ),
                recognizer: offline
                    ? null
                    : (TapGestureRecognizer()
                      ..onTap = () {
                        _launchExternalURL('https://note.com/nonokapiano/n/nec5b8a045d5d');
                      }),
              ),
              const TextSpan(text: ' に同意したことになります。'),
            ],
          ),
        ),
      );
    },
  );
}

  /// 既存クラスに参加するUI
  Widget _buildJoinClassArea() {
  return StreamBuilder<ConnectivityResult>(
    // 防御的記述で、リストが空の場合は ConnectivityResult.none を返す
    stream: Connectivity().onConnectivityChanged.map(
      (results) => results.isNotEmpty ? results.first : ConnectivityResult.none,
    ),
    builder: (context, snapshot) {
      // snapshot.data が null の場合はデフォルトでオンライン（または任意のデフォルト値）とする
      final connectivityResult = snapshot.data ?? ConnectivityResult.mobile;
      final offline = connectivityResult == ConnectivityResult.none;

      return Column(
        children: [
          TextField(
            controller: classIdForJoinController,
            decoration: const InputDecoration(labelText: 'クラスID'),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[A-Za-z0-9\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF@_\-]'),
              ),
              LengthLimitingTextInputFormatter(10),
            ],
          ),
          TextField(
            controller: classPasswordForJoinController,
            decoration: InputDecoration(
              labelText: 'パスワード',
              helperText: '大文字、小文字、数字の組み合わせで6文字以上',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureJoinPassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: _showJoinPasswordTemporarily,
                tooltip: 'パスワードを一時的に表示',
              ),
            ),
            obscureText: _obscureJoinPassword,
            inputFormatters: [
              LengthLimitingTextInputFormatter(10),
            ],
          ),
          const SizedBox(height: 16),
          _buildAgreementText(),
          const SizedBox(height: 16),
          ElevatedButton(
            // オフラインの場合は onPressed を null にしてボタンを無効化
            onPressed: offline
                ? null
                : () async {
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
    },
  );
}


  /// 「クラスを作成」ボタン押下時の処理
  void _onPressCreateClass() {
    final className = classNameController.text.trim();
    final classId = classIdForCreateController.text.trim();
    final password = classPasswordForCreateController.text.trim();
    final members = memberControllers
        .map((ctrl) => ctrl.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    if (className.isEmpty || classId.isEmpty || password.isEmpty) {
      _showMessage('未入力の項目があります');
      return;
    }
    if (!_validatePassword(password)) {
      _showMessage('パスワードは大文字、小文字、数字の組み合わせで6文字以上でないと承認されません');
      return;
    }
    if (members.length < 2) {
      _showMessage('メンバーは最低2人必要です');
      return;
    }
        if (members.length > 80) {
      _showMessage('メンバーは最大80人までです\nクラスを分けてください。');
      return;
    }
    final uniqueNames = members.toSet();
    if (uniqueNames.length != members.length) {
      _showMessage('名前が重複しています');
      return;
    }

    FocusScope.of(context).unfocus();

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

  /// 確認画面から「進む」ボタンを押した時に呼ばれるメソッド
  /// ※ クラス作成 → 参加フロー
Future<void> _joinClassAfterConfirm(
  String className,
  String classId,
  String password,
  List<String> trimmedNames,
) async {
  if (_isLoading) return;
  setState(() {
    _isLoading = true;
  });

  try {
    final classRef = FirebaseFirestore.instance.collection('classes').doc(classId);
    final docSnap = await classRef.get();
    if (docSnap.exists) {
      _showMessage('クラスIDがもう使われています');
      return;
    }

    await classRef.set({
      'id': classId,
      'name': className,
      'password': password,
      'createdAt': DateTime.now(),
    });

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
      MaterialPageRoute(builder: (context) => SelectAccountPage(classId: classId, className: className)),
      (route) => false,
    );
  } on FirebaseException catch (e) {
    if (e.code == 'unavailable') {
      return;
    } else {
      _showMessage('Firebaseエラー: ${e.message}');
    }
  } catch (e) {
    _showMessage('エラー: $e');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  Future<void> _joinClass(String classId, String password, String className) async {
  if (_isLoading) return;

  if (classId.isEmpty || password.isEmpty) {
    _showMessage('クラスIDとパスワードを入力してください');
    return;
  }
  if (!_validatePassword(password)) {
    _showMessage('パスワードは大文字、小文字、数字の組み合わせで6文字以上でないと承認されません');
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
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

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SelectAccountPage(classId: classId, className: className)),
      (route) => false,
    );
  } on FirebaseException catch (e) {
    if (e.code == 'unavailable') {
        return;
    } else {
      _showMessage('Firebaseエラー: ${e.message}');
    }
  } catch (e) {
    _showMessage('エラー: $e');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('確認'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 内容部分をCardで囲む
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'クラス名 ${widget.className}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'クラスID ${widget.classId}',
                        style: const TextStyle(fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'パスワード ${widget.password}',
                        style: const TextStyle(fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'メンバー',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 各メンバーの名前を表示
                      ...widget.members.map(
                        (member) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            member,
                            style: const TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // 注意文言
              Center(
                child: Text(
                  'クラス作成後は編集できません。\nよろしいですか？',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              // ボタンエリア
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '編集',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  // Connectivity のストリームを利用して接続状態を監視
                  StreamBuilder<ConnectivityResult>(
                    stream: Connectivity().onConnectivityChanged.map(
                      (results) => results.isNotEmpty ? results.first : ConnectivityResult.none,
                    ),
                    builder: (context, snapshot) {
                      // snapshot.data が null の場合はオンライン（例: ConnectivityResult.mobile）と仮定
                      final connectivityResult = snapshot.data ?? ConnectivityResult.mobile;
                      final offline = connectivityResult == ConnectivityResult.none;
                      return ElevatedButton(
                        onPressed: offline ? null : widget.onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkBlueColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '進む',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
