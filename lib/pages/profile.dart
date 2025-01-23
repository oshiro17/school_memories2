import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'calss_member_model.dart';
import 'each_profile.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DummyProfileModel(),
      child: Scaffold(
        body: Consumer<DummyProfileModel>(
          builder: (context, model, child) {
            final classMemberList = model.classMemberList;

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blueAccent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.3, 0.7],
                ),
              ),
              child: model.name.isNotEmpty
                  ? classMemberList.isNotEmpty
                      ? PageView.builder(
                          itemCount: classMemberList.length,
                          controller: PageController(viewportFraction: 0.8),
                          itemBuilder: (context, index) {
                            final member = classMemberList[index];
                            return GestureDetector(
                              onTap: () {
                                // 詳細ページへ遷移
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EachProfilePage(member: member),
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 5.0,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            width: 250,
                                            child: Text(
                                              member.subject,
                                              softWrap: true,
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w900,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                          Text(
                                            member.name,
                                            style: TextStyle(
                                              fontSize: 30,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text('クラスに他のメンバーがいません🥺'),
                        )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('まだプロフィールが設定されていません！'),
                          Text('早速設定しよう'),
                          SizedBox(height: 10),
                          Container(
                            height: 50,
                            child: TextButton(
                              onPressed: () {
                                // 設定ページ遷移処理（現在は未実装）
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  constraints: BoxConstraints(
                                    minHeight: 50,
                                    maxWidth: 300,
                                  ),
                                  child: Text(
                                    "設定する",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}

// DummyProfileModelの仮実装
class DummyProfileModel extends ChangeNotifier {
  String name = "デフォルトユーザー";
  List<Member> classMemberList = [
    Member(
      name: "田中 太郎",
      birthday: "2000-01-01",
      subject: "数学",
    ),
    Member(
      name: "山田 花子",
      birthday: "1999-12-31",
      subject: "英語",
    ),
  ];
}
