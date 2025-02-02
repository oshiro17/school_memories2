import 'dart:async';
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
  bool _obscureText = true; // 初期はパスワード非表示

  /// パスワードのバリデーション（大文字、小文字、数字の組み合わせで6文字以上）
  bool _validatePassword(String password) {
    // 正規表現: 少なくとも1つの大文字、1つの小文字、1つの数字、6文字以上
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{6,}$');
    return regex.hasMatch(password);
  }

  Future<void> _changePassword() async {
    final newPass = _passwordController.text.trim();

    if (newPass.isEmpty) {
      // 入力チェック
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('パスワードを入力してください')),
      );
      return;
    }

    // パスワードのバリデーションチェック
    if (!_validatePassword(newPass)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'パスワードは大文字、小文字、数字の組み合わせで6文字以上でないと承認されません',
          ),
        ),
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

  /// パスワード表示を一時的に有効にする
  void _showPasswordTemporarily() {
    setState(() => _obscureText = false);
    // 3秒後に自動で非表示に戻す
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _obscureText = true);
      }
    });
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
            decoration: InputDecoration(
              labelText: '新しいパスワード',
              // ヒント文（ヘルパーテキスト）を表示
              helperText: '大文字、小文字、数字の組み合わせで6文字以上である必要があります',
              // パスワード表示を一時的に可能にするボタンを追加
              suffixIcon: IconButton(
                icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                onPressed: _showPasswordTemporarily,
                tooltip: 'パスワードを一時的に表示',
              ),
            ),
            obscureText: _obscureText,
            inputFormatters: [
              LengthLimitingTextInputFormatter(10), // 最大10文字に制限
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
