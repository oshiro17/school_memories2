import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfileModel extends ChangeNotifier {
  String name = '';
  String birthday = '';
  String age = '';
  String subject = '';
  String food = '';
  String dream = '';
  String hobby = '';
  String advantage = '';
  String imageURL = '';

  /// 初期化処理（仮データをキャッシュから取得）
  
  Future<void> init(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString('name') ?? '';
    birthday = prefs.getString('birthday') ?? '';
    subject = prefs.getString('subject') ?? '';
    imageURL = prefs.getString('imageURL') ?? '';
    notifyListeners();
  }
}
  /// キャッシュからデータをロード