import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:school_memories2/class_model.dart';
import 'package:school_memories2/pages/home.dart';
import 'package:school_memories2/pages/myprofile_model.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectAccountPage extends StatefulWidget {
  final String classId;
  final String className;
  const SelectAccountPage({Key? key, required this.classId, required this.className}) : super(key: key);

  @override
  State<SelectAccountPage> createState() => _SelectAccountPageState();
}

class _SelectAccountPageState extends State<SelectAccountPage> {
  final Color _backgroundColor = Colors.white;
  final Color _darkBlueColor = const Color(0xFF1E3A8A);
  final Color _goldColor = const Color(0xFFFFD700);
  final Color _blackColor = Colors.black;

  List<Map<String, dynamic>> members = [];
  String? selectedMemberId;
  final passController = TextEditingController();
  

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('members')
          .get();

      setState(() {
        members = snap.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      _showMessage('メンバーの取得に失敗しました: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _darkBlueColor,
        title: const Text('あなたのアカウントを選択', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: members.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView( // 修正: Columnをスクロール可能に
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                     _buildMemberList(),
                      Text(
          'パスワードの初期値は 0000 です。\nあとで必ずパスワードは変更してね',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Text(
          'パスワードを入力してください。',
          style: TextStyle(fontSize: 14, color: _blackColor, fontWeight: FontWeight.bold),
        ),
                  //   SizedBox(
                  //     height: 300, // 修正: ListViewの高さを固定
                  //     child: _buildMemberList(),
                  //   ),
                  //   // const SizedBox(height: 16),
                    const SizedBox(height: 8),
                    _buildAgreementText(),
                    const SizedBox(height: 8),
                    _buildPasswordInput(),
                    const SizedBox(height: 24),
                    _buildLoginButton(),
                  //   // const SizedBox(height: 16),
                  //   _buildFooter(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMemberList() {
    return ListView.builder(
      shrinkWrap: true, // 修正: ListViewをColumn内で縮小
      physics: const NeverScrollableScrollPhysics(), // 修正: 内部スクロールを無効化
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        final memberName = member['name'] ?? '名無し';
        final memberId = member['id'] as String?;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: RadioListTile<String>(
            title: Text(
              memberName,
              style: TextStyle(
                color: _blackColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            activeColor: _darkBlueColor,
            value: memberId ?? '',
            groupValue: selectedMemberId,
            onChanged: (value) {
              setState(() => selectedMemberId = value);
            },
          ),
        );
      },
      // _buildPasswordInfo(),
    );
  }

  Widget _buildPasswordInfo() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Text(
          'パスワードの初期値は 0000 です。\nあとで必ずパスワードは変更してね',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
Text(
  '本人の同意がないログインや\nなりすまし行為は固く禁止されています。',
  style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold),
),
      ],
    );
  }

  Widget _buildPasswordInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
  //       inputFormatters: [
  //   LengthLimitingTextInputFormatter(10), // 文字数制限
  //   inputFormatter, // 文字制限
  // ],
        controller: passController,
        obscureText: true,
        style: TextStyle(color: _blackColor),
        decoration: const InputDecoration(
          labelText: 'パスワード',
          hintText: '初期値:0000',
          border: InputBorder.none,
        ),
        inputFormatters: [
          LengthLimitingTextInputFormatter(10),
        ],
      ),
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

 Widget _buildLoginButton() {
  return StreamBuilder<ConnectivityResult>(
    stream: Connectivity().onConnectivityChanged.map(
      (results) => results.isNotEmpty ? results.first : ConnectivityResult.none,
    ),
    builder: (context, snapshot) {
      // snapshot.data が null の場合はオンライン（ConnectivityResult.mobile）と仮定する
      final connectivityResult = snapshot.data ?? ConnectivityResult.mobile;
      final offline = connectivityResult == ConnectivityResult.none;
      
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _darkBlueColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          // オフラインの場合は onPressed を null にしてボタンを無効化
          onPressed: offline ? null : _onLoginPressed,
          child: const Text(
            'ログイン',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    },
  );
}


  Future<void> _onLoginPressed() async {
    if (selectedMemberId == null) {
      _showMessage('メンバーを選択してください');
      return;
    }
    final inputPass = passController.text.trim();
    if (inputPass.isEmpty) {
      _showMessage('パスワードを入力してください');
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('members')
          .doc(selectedMemberId!)
          .get();

      if (!doc.exists) {
        _showMessage('メンバー情報が存在しません');
        return;
      }

      final storedPass = doc.data()?['loginPassword'] ?? '0000';
      if (inputPass != storedPass) {
        _showMessage('パスワードが違います');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('savedClassId', widget.classId);
      await prefs.setString('savedMemberId', selectedMemberId!);
      await prefs.setString('savedClassName', widget.className);

      _showMessage('ログイン成功！');

      final classInfo = ClassModel(id: widget.classId, name: widget.className);
      final model = context.read<MyProfileModel>();
      await model.fetchProfileOnce(classInfo.id, selectedMemberId!);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => Home(
            classInfo: classInfo,
            currentMemberId: selectedMemberId!,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      _showMessage('ログイン中にエラーが発生しました: $e');
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: _darkBlueColor.withOpacity(0.9),
      ),
    );
  }
}
