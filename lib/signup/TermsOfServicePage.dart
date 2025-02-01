import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('利用規約'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '利用規約',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                '1. はじめに\n'
                'この利用規約（以下「本規約」）は、「卒業文集」（以下「本アプリ」）の利用条件を定めるものです。本アプリを利用することで、本規約に同意したものとみなされます。本アプリは、クラスメイト同士が思い出を共有することを目的としています。',
              ),
              SizedBox(height: 16),
              Text(
                '2. ユーザーの責任\n'
                '・他人に迷惑をかける行為や不適切なメッセージの送信は禁止です。\n'
                '・虚偽の情報の登録は禁止です。\n'
                '・ユーザーは自己責任のもとで本アプリを利用するものとします。',
              ),
              SizedBox(height: 16),
              Text(
                '3. 禁止事項\n'
                '・不正アクセスやシステムの改ざん\n'
                '・他人への嫌がらせや誹謗中傷行為\n'
                '・第三者の権利を侵害する行為',
              ),
              SizedBox(height: 16),
              Text(
                '4. 知的財産権\n'
                '・本アプリ内のコンテンツ（テキスト、デザイン、ロゴ等）の著作権は開発者に帰属します。\n'
                '・ユーザーが投稿した内容の著作権は投稿者に帰属しますが、アプリ内での使用許可を与えたものとみなします。',
              ),
              SizedBox(height: 16),
              Text(
                '5. 免責事項\n'
                '・本アプリは基本的なセキュリティ対策を講じていますが、完全なデータ保護は保証できません。\n'
                '・データの漏洩や損害が発生した場合でも、開発者は一切の責任を負いません。',
              ),
              SizedBox(height: 16),
              Text(
                '6. ユーザー情報の修正・削除について\n'
                '・本アプリには、ユーザー自身が提供した情報を修正・削除するための機能はありません。\n'
                '・情報の修正や削除を希望する場合は、アプリ内のお問い合わせください。',
              ),
              SizedBox(height: 16),
              Text(
                '7. 規約の変更\n'
                '・本規約は予告なく変更されることがあります。変更後の利用は、変更内容に同意したものとみなされます。',
              ),
              SizedBox(height: 16),
              Text(
                '8. 準拠法および管轄\n'
                '・本規約は日本法に準拠します。\n'
                '・本アプリに関連して紛争が生じた場合、東京地方裁判所を第一審の専属的合意管轄裁判所とします。',
              ),
              SizedBox(height: 16),
              Text(
                '9. お問い合わせ\n'
                '本規約に関するご質問は、以下のメールアドレスまたはTwitterアカウントまでご連絡ください。\n\n'
                'メール: nonokuwapiano@gmail.com\n'
                'Twitter: https://twitter.com/ora_nonoka',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
