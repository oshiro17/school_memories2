import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ★ Firestoreの操作に必要
import 'package:school_memories2/pages/block.dart';
import 'package:school_memories2/pages/write_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:school_memories2/class_model.dart';
import 'package:school_memories2/pages/change_password_dialog.dart';
import 'package:school_memories2/pages/vote.dart';
import 'package:school_memories2/signup/class_selection_page.dart';
import 'package:school_memories2/signup/select_account_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async'; // ★ カウントダウン用のTimerに必要

class MainMemoriesDialog extends StatelessWidget {
  final ClassModel classInfo;
  final String currentMemberId;

  const MainMemoriesDialog({
    required this.classInfo,
    required this.currentMemberId,
    Key? key,
  }) : super(key: key);

  // 外部ブラウザで URL を開くヘルパー関数
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  /// アカウント削除処理全体
  /// 1) 10秒のカウントダウンダイアログを表示
  /// 2) 「キャンセル」押下で削除を中断 / タイムアウトで削除実行
  Future<void> _confirmAccountDeletion(BuildContext context) async {
    // カウントダウンダイアログを表示して結果を受け取る
    final bool canceled = await showDialog<bool>(
      context: context,
      // ダイアログ外をタップしても閉じない
      barrierDismissible: false,
      builder: (_) => const _CountdownDialog(),
    ) ?? true; 
    // showDialogがnullを返す可能性があるため、デフォルトでtrue(キャンセル扱い)

    // ユーザーがキャンセルを押した場合は true が返るので処理中断
    if (canceled) {
      return;
    }

    // キャンセルされず10秒経過した → Firestore & SharedPreferences 削除実行

    // 1) Firestore で該当ユーザー情報を消去
    final docRef = FirebaseFirestore.instance
        .collection('classes')
        .doc(classInfo.id)
        .collection('members')
        .doc(currentMemberId);

    try {
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          // name と avatarIndex 以外のフィールドを削除
          final Map<String, dynamic> updateData = {};
          for (final key in data.keys) {
            if (key != 'name' && key != 'avatarIndex' && key!= 'id') {
              updateData[key] = FieldValue.delete();
            }
          }
          if (updateData.isNotEmpty) {
            await docRef.update(updateData);
          }
          // name と avatarIndex を上書き
          await docRef.update({
            'name': 'unknown',
            'avatarIndex': 0,
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('アカウント情報の消去に失敗しました: $e')),
      );
      return;
    }

    // 2) SharedPreferences の情報を消去
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('savedClassId');
      await prefs.remove('savedMemberId');
      await prefs.remove('savedClassName');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('内部データの消去に失敗しました: $e')),
      );
      return;
    }

    // 3) SnackBarを表示してから ClassSelectionPage に遷移
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('アカウント情報を消去しました')),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => ClassSelectionPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityResult>(
      // 最新の Connectivity Plus では onConnectivityChanged が単一 ConnectivityResult をストリームで返す
        stream: Connectivity().onConnectivityChanged.map(
    (results) => results.isNotEmpty ? results.first : ConnectivityResult.none,
  ),
      builder: (context, snapshot) {
        // snapshot.data が null の場合はオンライン状態（例: ConnectivityResult.mobile）と仮定
        final connectivityResult = snapshot.data ?? ConnectivityResult.mobile;
        final bool isOffline = connectivityResult == ConnectivityResult.none;

        // オンライン時に表示する項目一覧
        final List<Widget> onlineOptions = [
                    SimpleDialogOption(
            child: const Text('友達をブロックする'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>  BlockPage(
                    classId: classInfo.id,
                    currentMemberId: currentMemberId,
                  ),
                ),
              );
            },
          ),
          SimpleDialogOption(
            child: const Text('寄せ書きを書く'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WriteMessagePage(
                    classId: classInfo.id,
                    currentMemberId: currentMemberId,
                  ),
                ),
              );
            },
          ),
          SimpleDialogOption(
            child: const Text('ランキングを投票する'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VoteRankingPage(
                    classId: classInfo.id,
                    currentMemberId: currentMemberId,
                  ),
                ),
              );
            },
          ),
          SimpleDialogOption(
            child: const Text('他のクラスにログインする'),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('savedClassId');
              await prefs.remove('savedMemberId');
              await prefs.remove('savedClassName');
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ClassSelectionPage()),
              );
            },
          ),
          SimpleDialogOption(
            child: const Text('他のメンバーでログインする'),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('savedMemberId');
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SelectAccountPage(
                    classId: classInfo.id,
                    className: classInfo.name,
                  ),
                ),
              );
            },
          ),
          SimpleDialogOption(
            child: const Text('パスワードを変更する'),
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) {
                  return ChangePasswordDialog(
                    classId: classInfo.id,
                    memberId: currentMemberId,
                  );
                },
              );
            },
          ),
          // 利用規約へのリンク
          SimpleDialogOption(
            child: const Text('利用規約'),
            onPressed: () {
              Navigator.pop(context);
              _launchURL('https://note.com/nonokapiano/n/nec5b8a045d5d');
            },
          ),
          // プライバシーポリシーへのリンク
          SimpleDialogOption(
            child: const Text('プライバシーポリシー'),
            onPressed: () {
              Navigator.pop(context);
              _launchURL('https://note.com/nonokapiano/n/nede64e2d5743');
            },
          ),
          // お問い合わせ・報告
          SimpleDialogOption(
            child: const Text('お問い合わせ\n不適切ユーザーの報告'),
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: const Text('お問い合わせ 報告'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('メール: nonokuwapiano@gmail.com'),
                        SizedBox(height: 8),
                        Text('X: @ora_nonoka'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('閉じる'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          // ★ ここに "アカウント情報を消去する" の項目を追加
          SimpleDialogOption(
            child: const Text('アカウント情報を消去する'),
            onPressed: () {
              Navigator.pop(context);
              _confirmAccountDeletion(context);
            },
          ),
        ];

        // オフラインの場合は「戻る」ボタンのみ表示
        final List<Widget> options = isOffline
            ? [
                SimpleDialogOption(
                  child: const Text('戻る'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ]
            : onlineOptions;

        return SimpleDialog(
          title: const Text('メニュー'),
          children: options,
        );
      },
    );
  }
}

/// 10秒カウントダウン用のダイアログウィジェット
/// - キャンセルで [true] を返して削除を中断
/// - タイムアウトで [false] を返して削除実行
class _CountdownDialog extends StatefulWidget {
  const _CountdownDialog({Key? key}) : super(key: key);

  @override
  State<_CountdownDialog> createState() => _CountdownDialogState();
}

class _CountdownDialogState extends State<_CountdownDialog> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = 10; // 10秒のカウントダウン
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        // タイムアウト → false(削除実行)
        Navigator.pop(context, false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('本当に消去しますか？'),
      content: Text(
        'キャンセルを $_remainingSeconds 秒以内に押さないと\n'
        'アカウントが完全に消去されます。',
      ),
      actions: [
        TextButton(
          onPressed: () {
            // キャンセルを押した → true(削除中断)
            Navigator.pop(context, true);
          },
          child: const Text('キャンセル'),
        ),
      ],
    );
  }
}
