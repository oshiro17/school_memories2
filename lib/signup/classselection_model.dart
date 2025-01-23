import 'package:flutter/material.dart';

class Clas {
  final String name;
  final String id;

  Clas({required this.name, required this.id});
}

class ClassSelectionModel extends ChangeNotifier {
  // 仮のデータ
  String userId = 'testUser';
  String userName = 'テストユーザー';
  String userComment = 'テストコメント';
  String userImageURL = 'https://www.google.com/imgres?q=%E3%82%AC%E3%83%83%E3%82%AD%E3%83%BC&imgurl=https%3A%2F%2Fupload.wikimedia.org%2Fwikipedia%2Fcommons%2Fthumb%2F5%2F54%2FAragaki_Yui_from_%2522%2528Ab%2529normal_Desire%2522_at_Red_Carpet_of_the_Tokyo_International_Film_Festival_2023_%252853347233892%2529_%2528cropped%2529.jpg%2F1200px-Aragaki_Yui_from_%2522%2528Ab%2529normal_Desire%2522_at_Red_Carpet_of_the_Tokyo_International_Film_Festival_2023_%252853347233892%2529_%2528cropped%2529.jpg&imgrefurl=https%3A%2F%2Fja.wikipedia.org%2Fwiki%2F%25E6%2596%25B0%25E5%259E%25A3%25E7%25B5%2590%25E8%25A1%25A3&docid=aFzOwYbMItADgM&tbnid=YmaSAnwPc1X-PM&vet=12ahUKEwj9wK_hp4KLAxXzafUHHSwVFkwQM3oECGwQAA..i&w=1200&h=1599&hcb=2&ved=2ahUKEwj9wK_hp4KLAxXzafUHHSwVFkwQM3oECGwQAA';
  String className = '';
  Clas? attendingClass;

  TextEditingController classNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  TextEditingController classNumberForJoinController = TextEditingController();
  TextEditingController passwordForJoinController = TextEditingController();

  Future<void> init(BuildContext context) async {
    // Firebase未設定環境用に初期化ロジックを仮実装
    userId = 'dummyUserId';
    userName = '仮ユーザー';
    userComment = 'このユーザーはダミーです';
    userImageURL = 'https://www.google.com/imgres?q=%E3%82%AC%E3%83%83%E3%82%AD%E3%83%BC&imgurl=https%3A%2F%2Fwww.crank-in.net%2Fimg%2Fdb%2F1254333_650.jpg&imgrefurl=https%3A%2F%2Fwww.crank-in.net%2Fnews%2F56626%2F1&docid=jBHU-dFGVAjcpM&tbnid=GuDUNMC8CeoGgM&vet=12ahUKEwj9wK_hp4KLAxXzafUHHSwVFkwQM3oECB0QAA..i&w=650&h=488&hcb=2&ved=2ahUKEwj9wK_hp4KLAxXzafUHHSwVFkwQM3oECB0QAA';
    notifyListeners();
  }

  String? validateClassNumberCallback(String? value) {
    if (value == null || value.isEmpty) {
      return 'クラスIDを入力してください';
    } else if (value.length > 10) {
      return '10字以内でご記入ください';
    }
    return null;
  }

  String? validatePasswordCallback(String? value) {
    if (value == null || value.isEmpty) {
      return 'パスワードを入力してください';
    } else if (value.length > 10) {
      return '10字以内でご記入ください';
    }
    return null;
  }

  String? validateNameCallback(String? value) {
    if (value == null || value.isEmpty) {
      return 'クラス名を入力してください';
    } else if (value.length > 10) {
      return '10字以内でご記入ください';
    }
    return null;
  }

  // Future<bool> createClass() async {
  //   // Firebase未設定環境ではダミーロジックを追加
  //   if (classNumberController.text == 'existingClass') {
  //     return false; // クラスIDが重複している場合
  //   }
  //   className = nameController.text;
  //   attendingClass = Class(className); // 仮クラスを作成
  //   notifyListeners();
  //   return true;
  // }

Future<bool> createClass() async {
  // Firebase未設定環境ではダミーロジックを追加
  if (classNumberController.text == 'existingClass') {
    return false; // クラスIDが重複している場合
  }
  className = nameController.text;
  attendingClass = Clas(
    name: className, 
    id: classNumberController.text, // 必要に応じて適切な値を設定
  );
  notifyListeners();
  return true;
}

  Future<void> joinClass() async {
  // ダミーロジックでクラスへの参加をシミュレート
  if (classNumberForJoinController.text == 't' &&
      passwordForJoinController.text == '1') {
    className = 'テストクラス';
    attendingClass = Clas(
      name: className,
      id: classNumberForJoinController.text, // クラスIDを設定
    );
    notifyListeners();
  } else {
    throw 'クラスIDかパスワードが間違っています';
  }
}


  Future<bool> isJoinedClass() async {
    // ダミーロジックで参加状況をチェック
    return attendingClass != null;
  }

 Future<bool> classExists() async {
  // ダミーロジックでクラスの存在を確認
  if (classNumberForJoinController.text == 'testClass') {
    className = 'テストクラス';
    attendingClass = Clas(
      name: className,
      id: classNumberForJoinController.text, // クラスIDを設定
    );
    return true;
  }
  return false;
}

  @override
  void dispose() {
    classNumberController.dispose();
    passwordController.dispose();
    nameController.dispose();
    classNumberForJoinController.dispose();
    passwordForJoinController.dispose();
    super.dispose();
  }

  /// デフォルトのランキングを作成する
  Future<void> createDefaultRanking({
    required String classId,
    required String rankingName,
  }) async {
    // Firebase依存ロジックを削除
    print('デフォルトランキング作成: $rankingName');
  }
}

// lib/models/class.dart

