import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_memories2/pages/home.dart';
import 'package:school_memories2/class_model.dart';

class SelectAccountPage extends StatefulWidget {
  final String classId;

  const SelectAccountPage({Key? key, required this.classId}) : super(key: key);

  @override
  State<SelectAccountPage> createState() => _SelectAccountPageState();
}

class _SelectAccountPageState extends State<SelectAccountPage> {
  List<Map<String, dynamic>> members = [];
  String? selectedMemberId;
  final passController = TextEditingController(); // 初期パスワード用

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

    final list = snap.docs.map((doc) => doc.data()).toList();
    setState(() {
      members = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('あなたのアカウントを選択'),
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
                          setState(() {
                            selectedMemberId = value;
                          });
                        },
                      );
                    },
                  ),
                ),
                const Text('初期パスワード「0000」を入力してください。'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: passController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'パスワード',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedMemberId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('メンバーを選択してください。')),
                      );
                      return;
                    }
                    if (passController.text.trim() != '0000') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('パスワードが間違っています。')),
                      );
                      return;
                    }

                    // ここで Home へ遷移する
                    final classInfo = ClassModel(
                      id: widget.classId,
                      classNumber: '', // 必要に応じて入れてください
                      name: '',
                      password: '0000',
                      userCount: 0,
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Home(classInfo: classInfo),
                      ),
                    );
                  },
                  child: const Text('ログイン'),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }

  @override
  void dispose() {
    passController.dispose();
    super.dispose();
  }
}
