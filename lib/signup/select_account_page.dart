import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
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
      appBar: AppBar(
        title: const Text('あなたのアカウントを選択'),
      ),
      body: members.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return RadioListTile<String>(
                        title: Text(member['name'] ?? '名無し'),
                        value: member['id'],
                        groupValue: selectedMemberId,
                        onChanged: (value) {
                          setState(() => selectedMemberId = value);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                  Text('パスワードの初期値は0000です。', 
      style: TextStyle(fontSize: 12, color: Colors.grey),
    ),
                  Text('あとでパスワードは変更してね', 
      style: TextStyle(fontSize: 12, color: Colors.grey),
    ),
                const Text('パスワードを入力してください。'), // ← もはや"初期"に限定しない
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: passController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'パスワード',
                      hintText: '0000',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _onLoginPressed,
                  child: const Text('ログイン'),
                ),
                const SizedBox(height: 20),
              ],
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

    // 選択した memberId の Firestore doc を取得して、loginPassword を照合
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
    // loginPassword が無い場合は '0000' を初期値とする

    if (inputPass != storedPass) {
      _showMessage('パスワードが違います');
      return;
    }

    // パスワードOK -> Homeへ移動
    // print('classnameだせ');
    print(widget.className);
    final classInfo = ClassModel(
      id: widget.classId,
      name: widget.className,
      // password: '', 
      // userCount: 0,
    );
            final model = context.read<MyProfileModel>();
            await model.fetchProfileOnce(classInfo.id, selectedMemberId!);
       
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => Home(
          classInfo: classInfo,
          currentMemberId: selectedMemberId!,
        ),
      ),
    );
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
