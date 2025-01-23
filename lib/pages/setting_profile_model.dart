import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingProfileModel extends ChangeNotifier {

   Future<void> saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', nameController.text);
    await prefs.setString('birthday', birthdayController.text);
    await prefs.setString('subject', subjectController.text);
    await prefs.setString('imageURL', imageURL);
    notifyListeners();
  }
  String? validateText(String? value) {
    if (value == null || value.isEmpty) {
      return 'このフィールドは必須です。';
    } else if (value.length > 50) {
      return '50文字以内で入力してください。';
    }
    return null;
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController birthdayController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  String imageURL = '';

  bool isLoading = false;

  /// 初期化処理
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    nameController.text = prefs.getString('name') ?? '';
    birthdayController.text = prefs.getString('birthday') ?? '';
    subjectController.text = prefs.getString('subject') ?? '';
    imageURL = prefs.getString('imageURL') ?? '';
  }

  /// プロフィールをキャッシュに保存
  Future<void> saveToCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', nameController.text);
    await prefs.setString('birthday', birthdayController.text);
    await prefs.setString('subject', subjectController.text);
    await prefs.setString('imageURL', imageURL);
    notifyListeners();
  }

  /// プロフィール画像を選択
/// プロフィール画像を選択
Future<void> pickImage(ImageSource source) async {
  final pickedFile = await ImagePicker().pickImage(source: source);
  if (pickedFile != null) {
    imageURL = pickedFile.path; // ローカルパスを保存
    await saveToCache(); // キャッシュに保存
    await init(); // 再ロードしてUIに反映
    notifyListeners();
  }
}


  @override
  void dispose() {
    nameController.dispose();
    birthdayController.dispose();
    subjectController.dispose();
    super.dispose();
  }
}
