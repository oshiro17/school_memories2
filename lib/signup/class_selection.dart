import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'classselection_model.dart';
import '../pages/home.dart'; // HomePageをインポート

class ClassselectionPage extends StatefulWidget {
  @override
  _ClassselectionPage createState() => _ClassselectionPage();
}

class _ClassselectionPage extends State<ClassselectionPage> {
  final _formKey = GlobalKey<FormState>();
  bool makeclass = true;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ClassSelectionModel>(
      create: (context) => ClassSelectionModel()..init(context),
      child: Scaffold(
        body: Consumer<ClassSelectionModel>(
          builder: (context, model, child) {
            return Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  child: Container(
                    height: 430,
                    padding: EdgeInsets.only(top: 200, left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "卒業文集へようこそ",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          makeclass ? 'クラスを作る' : "既存のクラスに参加する",
                          style: TextStyle(
                            letterSpacing: 3,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: Duration(milliseconds: 600),
                  curve: Curves.bounceInOut,
                  top: 300,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 0),
                    curve: Curves.bounceInOut,
                    height: makeclass ? 350 : 300,
                    padding: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width - 40,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    makeclass = false;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      "クラスに参加",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    if (!makeclass)
                                      Container(
                                        margin: EdgeInsets.only(top: 3),
                                        height: 2,
                                        width: 55,
                                        color: Colors.blue,
                                      ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    makeclass = true;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      "クラスを作成",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    if (makeclass)
                                      Container(
                                        margin: EdgeInsets.only(top: 3),
                                        height: 2,
                                        width: 55,
                                        color: Colors.blue,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (makeclass) makeClass(model),
                          if (!makeclass) joinClass(model),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Container joinClass(ClassSelectionModel model) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'クラスのID'),
            controller: model.classNumberForJoinController,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'クラスのパスワード'),
            controller: model.passwordForJoinController,
          ),
          SizedBox(height: 25),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: EdgeInsets.all(12),
            ),
            onPressed: () async {
              try {
                // if (await model.classExists() == false) {
                //   _showErrorDialog(context, 'クラスが存在しません。');
                //   return;
                // }
                // if (await model.isJoinedClass() == true) {
                //   _showErrorDialog(context, '既に参加しています。');
                //   return;
                // }
                await model.joinClass();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home(classInfo: model.attendingClass!),
                  ),
                );
              } catch (e) {
                _showErrorDialog(context, e.toString());
              }
            },
            child: Text(
              '参加する',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Container makeClass(ClassSelectionModel model) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'クラスのID'),
              controller: model.classNumberController,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'クラスのパスワード'),
              controller: model.passwordController,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'クラス名'),
              controller: model.nameController,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: EdgeInsets.all(12),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    if (await model.createClass() == false) {
                      _showErrorDialog(context, 'クラスIDが既に使用されています。');
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Home(classInfo: model.attendingClass!),
                      ),
                    );
                  } catch (e) {
                    _showErrorDialog(context, e.toString());
                  }
                }
              },
              child: Text(
                '作成',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('エラー'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('閉じる'),
          ),
        ],
      ),
    );
  }
}
