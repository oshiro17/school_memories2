import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class ChangePasswordDialog extends StatefulWidget {
  final String classId;
  final String memberId;

  const ChangePasswordDialog({
    Key? key,
    required this.classId,
    required this.memberId,
  }) : super(key: key);

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _changePassword() async {
    final newPass = _passwordController.text.trim();
    if (newPass.isEmpty) {
      // 入力チェック
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('パスワードを入力してください')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Firestore のメンバー doc に新しいパスワードを更新
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('members')
          .doc(widget.memberId)
          .update({
        'loginPassword': newPass,
      });

      // 成功したらダイアログを閉じる
      Navigator.pop(context);
    } catch (e) {
      print('パスワード変更時にエラー: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラー: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('パスワードを変更'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: '新しいパスワード',
            ),
            obscureText: true, // パスワード非表示
             inputFormatters: [
    LengthLimitingTextInputFormatter(4), // 最大10文字に制限
  ],
          ),
        ],
      ),
      actions: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          )
        else
          TextButton(
            onPressed: _changePassword,
            child: const Text('変更する'),
          ),
      ],
    );
  }
}
