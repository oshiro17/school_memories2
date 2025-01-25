// class_selection_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/signup/class_selection_page.dart';
import '../pages/home.dart';
import '../class_model.dart';

class ClassSelectionPage extends StatefulWidget {
  @override
  State<ClassSelectionPage> createState() => _ClassSelectionPageState();
}

class _ClassSelectionPageState extends State<ClassSelectionPage> {
  bool makeClass = true;   // true: クラス作成, false: 既存クラスに参加
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ClassSelectionPageModel>(
      create: (_) => ClassSelectionPageModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('クラス作成 or 参加'),
        ),
        body: Consumer<ClassSelectionPageModel>(
          builder: (context, model, child) {
            return Stack(
              children: [
                IgnorePointer(
                  ignoring: isLoading,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => makeClass = false),
                              child: Column(
                                children: [
                                  const Text(
                                    "クラスに参加",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  if (!makeClass)
                                    Container(
                                      margin: const EdgeInsets.only(top: 3),
                                      height: 2,
                                      width: 80,
                                      color: Colors.blue,
                                    ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => makeClass = true),
                              child: Column(
                                children: [
                                  const Text(
                                    "クラスを作成",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  if (makeClass)
                                    Container(
                                      margin: const EdgeInsets.only(top: 3),
                                      height: 2,
                                      width: 80,
                                      color: Colors.blue,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (makeClass) _makeClassForm(context, model),
                        if (!makeClass) _joinClassForm(context, model),
                      ],
                    ),
                  ),
                ),
                if (isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _makeClassForm(BuildContext context, ClassSelectionPageModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'クラスのID (任意文字列)'),
              controller: model.classNumberController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'クラスのIDを入力してください。';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'クラスのパスワード'),
              controller: model.passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'クラスのパスワードを入力してください。';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'クラス名'),
              controller: model.nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'クラス名を入力してください。';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                setState(() => isLoading = true);
                try {
                  final createdClass = await model.createClass();
                  // 成功 → Homeへ
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Home(classInfo: createdClass),
                    ),
                  );
                } catch (e) {
                  _showErrorDialog(context, e.toString());
                } finally {
                  setState(() => isLoading = false);
                }
              },
              child: const Text('クラスを作成'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _joinClassForm(BuildContext context, ClassSelectionPageModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'クラスのID'),
            controller: model.classNumberForJoinController,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'クラスのパスワード'),
            controller: model.passwordForJoinController,
            obscureText: true,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              setState(() => isLoading = true);
              try {
                final joinedClass = await model.joinClass();
                // 成功 → Homeへ
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home(classInfo: joinedClass),
                  ),
                );
              } catch (e) {
                _showErrorDialog(context, e.toString());
              } finally {
                setState(() => isLoading = false);
              }
            },
            child: const Text('クラスに参加'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('エラー'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          )
        ],
      ),
    );
  }
}
