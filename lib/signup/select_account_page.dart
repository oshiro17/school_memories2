import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 追加

import 'package:school_memories2/class_model.dart';
import 'package:school_memories2/pages/home.dart';
import 'package:school_memories2/pages/myprofile_model.dart';

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
    final snap = await FirebaseFirestore.instance
        .collection('classes')
        .doc(widget.classId)
        .collection('members')
        .get();

    setState(() {
      members = snap.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _darkBlueColor,
        title: Text('あなたのアカウントを選択', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: members.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // メンバー一覧
                  Expanded(
                    child: ListView.builder(
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
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    'パスワードの初期値は 0000 です。\nあとでパスワードは変更してね',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'パスワードを入力してください。',
                    style: TextStyle(fontSize: 14, color: _blackColor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // パスワード入力
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: passController,
                      obscureText: true,
                      style: TextStyle(color: _blackColor),
                      decoration: const InputDecoration(
                        labelText: 'パスワード',
                        hintText: '0000',
                        border: InputBorder.none,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(4),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ログインボタン
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _darkBlueColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _onLoginPressed,
                      child: Text('ログイン', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    '© 2025 School Memories',
                    style: TextStyle(color: _goldColor.withOpacity(0.7), fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
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

    // 選択した memberId の Firestore ドキュメントを取得し、loginPassword をチェック
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

    // ========== ここでSharedPreferencesに保存する ==========
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedClassId', widget.classId);
    await prefs.setString('savedMemberId', selectedMemberId!);
    // =======================================================

    // パスワードOK -> Homeへ移動
    final classInfo = ClassModel(
      id: widget.classId,
      name: widget.className,
    );
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
