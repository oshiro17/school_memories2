import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_memories2/main.dart'; // navigatorKey が定義されているファイル
import 'package:school_memories2/offline_page.dart';

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
  String? errorMessage; // エラー状態を保持する変数

  Future<void> _changePassword() async {
    final newPass = _passwordController.text.trim();
    if (newPass.isEmpty) {
      // 入力チェック
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('パスワードを入力してください')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      errorMessage = null; // 処理開始時にエラー状態をリセット
    });

    try {
      // Firestore のメンバードキュメントに新しいパスワードを更新
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
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        // ネットワークエラーの場合、OfflinePage へ遷移
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => OfflinePage(error: e.message ?? 'Network error')),
          (route) => false,
        );
      } else {
        setState(() {
          errorMessage = 'Firestoreエラー: ${e.message}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'パスワード変更に失敗しました: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
            obscureText: true,
          ),
          // エラー発生時にエラーメッセージを表示
          if (errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
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
