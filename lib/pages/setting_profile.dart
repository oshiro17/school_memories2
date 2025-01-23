import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'setting_profile_model.dart';

class SettingProfilePage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingProfileModel>(
      create: (context) => SettingProfileModel()..init(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            'プロフィールを設定する',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 4.0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_outlined,
              color: Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Consumer<SettingProfileModel>(
          builder: (context, model, child) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 48.0,
                      horizontal: 24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// プロフィール画像
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              await showDialog(
                                context: context,
                                builder: (context) => SimpleDialog(
                                  title: Text('プロフィール画像を設定'),
                                  children: [
                                    SimpleDialogOption(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        try {
                                          await model.pickImage(ImageSource.camera);
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('カメラの使用中にエラーが発生しました: $e')),
                                          );
                                        }
                                      },
                                      child: Text('カメラで撮影'),
                                    ),
                                    SimpleDialogOption(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await model.pickImage(ImageSource.gallery);
                                      },
                                      child: Text('写真を選択'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: ClipOval(
                              child: model.imageURL.isNotEmpty
                                  ? Image.file(
                                      File(model.imageURL),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      Icons.account_circle,
                                      size: 100,
                                      color: Colors.grey,
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),

                        /// フォーム項目
                        buildProfileField(
                          label: '名前',
                          controller: model.nameController,
                          hintText: '例)大城太郎',
                          icon: Icons.face,
                          validator: model.validateText,
                        ),
                        buildProfileField(
                          label: '誕生日',
                          controller: model.birthdayController,
                          hintText: '例)2003.08.01',
                          icon: Icons.cake,
                          validator: model.validateText,
                        ),
                        buildProfileField(
                          label: '好きな教科',
                          controller: model.subjectController,
                          hintText: '例)数学',
                          icon: Icons.book,
                          validator: model.validateText,
                        ),

                        /// 更新ボタン
                        SizedBox(height: 40),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await model.saveProfile();
                                await model.init();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('プロフィールを更新しました')),
                                );
                              }
                            },
                            child: Text('更新する'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// プロフィール入力フィールド
  Widget buildProfileField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
