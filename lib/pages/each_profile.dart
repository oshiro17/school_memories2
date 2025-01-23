import 'package:flutter/material.dart';
import 'calss_member_model.dart';

class EachProfilePage extends StatelessWidget {
  final Member member;

  const EachProfilePage({Key? key, required this.member}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.blue,
      body: Stack(
        children: <Widget>[
          CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 450,
                backgroundColor:  Colors.blue,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage("https://www.google.com/imgres?q=%E3%82%AC%E3%83%83%E3"),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          print('Image load failed: $exception');
                        },
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomRight,
                          colors: [
                             Colors.blue,
                            ( Colors.blueAccent)
                                .withOpacity(0.0),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            member.name,
                            style: TextStyle(
                              color: const Color(0xFFA64AF5),
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  _buildProfileContent(member),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // プロフィール情報をリスト形式で作成
  List<Widget> _buildProfileContent(Member member) {
    return [
      const SizedBox(height: 20),
      _buildRowWithText('誕生日: ', member.birthday),
      _buildRowWithText('好きな教科: ', member.subject),
    ];
  }

  // テキストとデータを行で表示する
  Widget _buildRowWithText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 14.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color:  Colors.black54,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color:Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 質問と答えを表示するセクション
  Widget _buildQuestionSection(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8.0),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black54,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              answer,
              style: TextStyle(
                color:Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
