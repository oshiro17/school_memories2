import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:school_memories2/pages/write_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:school_memories2/class_model.dart';
import 'package:school_memories2/pages/change_password_dialog.dart';
import 'package:school_memories2/pages/vote.dart';
import 'package:school_memories2/signup/class_selection_page.dart';
import 'package:school_memories2/signup/select_account_page.dart';
import 'package:url_launcher/url_launcher.dart'; // 追加

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
      // エラー処理
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityResult>(
      // 最新の Connectivity Plus では、onConnectivityChanged は ConnectivityResult を返すので、そのまま利用します。
      stream: Connectivity().onConnectivityChanged.map(
        (results) => results.isNotEmpty ? results.first : ConnectivityResult.none,
      ),
      builder: (context, snapshot) {
        // snapshot.data が null の場合はオンライン状態（例: ConnectivityResult.mobile）と仮定する
        final connectivityResult = snapshot.data ?? ConnectivityResult.mobile;
        final bool isOffline = connectivityResult == ConnectivityResult.none;

        // オンライン時に表示する項目一覧
        final List<Widget> onlineOptions = [
          SimpleDialogOption(
            child: const Text('寄せ書きを書く'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WriteMessagePage(
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
                  builder: (context) => VoteRankingPage(
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
                MaterialPageRoute(
                  builder: (context) => ClassSelectionPage(),
                ),
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
                  builder: (context) => SelectAccountPage(
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
                builder: (context) {
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
                builder: (context) {
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
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('閉じる'),
                      ),
                    ],
                  );
                },
              );
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
