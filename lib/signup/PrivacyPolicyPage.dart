import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プライバシーポリシー'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'プライバシーポリシー',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                '1. はじめに\n'
                '「卒業文集」（以下「本アプリ」）は、ユーザーのプライバシーを尊重し、個人情報の保護に努めます。本ポリシーは、ユーザーの情報の収集、使用、保護に関する方針を説明します。',
              ),
              SizedBox(height: 16),
              Text(
                '2. 収集する情報\n'
                '・ユーザーが提供する情報（ニックネームなど）\n'
                '・Firestoreを通じて収集される利用データ',
              ),
              SizedBox(height: 16),
              Text(
                '3. 情報の使用目的\n'
                '・アプリ機能（メッセージ機能、プロフィール帳ランキング機能）の提供\n'
                '・サービスの改善およびバグ修正',
              ),
              SizedBox(height: 16),
              Text(
                '4. 情報の共有\n'
                '・ユーザー情報は第三者と共有されません。',
              ),
              SizedBox(height: 16),
              Text(
                '5. セキュリティについて\n'
                '・本アプリは基本的なセキュリティ対策を実施していますが、完全なセキュリティを保証するものではありません。個人情報の取扱いには十分ご注意ください。\n'
                '・重要な個人情報（本名、住所など）の入力は推奨しません。',
              ),
              SizedBox(height: 16),
              Text(
                '6. ユーザーの権利について\n'
                '・本アプリには、ユーザー自身が提供した情報を修正・削除するための機能は実装されておりません。\n'
                '・情報の修正・削除を希望される場合は、アプリ内のお問い合わせ機能からご連絡ください。',
              ),
              SizedBox(height: 16),
              Text(
                '7. 変更について\n'
                '・プライバシーポリシーの内容は予告なく変更されることがあります。',
              ),
              SizedBox(height: 16),
 Text(
  '8. お問い合わせ\n'
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
