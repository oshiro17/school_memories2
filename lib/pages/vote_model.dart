import 'package:flutter/material.dart';

class VoteRankingPageModel extends ChangeNotifier {
  VoteRankingPageModel({
    required this.classId,
    this.rankingList,
  });

  bool isLoading = false;

  final String classId;
  List<String>? rankingList; // ダミーのリストに置き換え
  final TextEditingController rankingController = TextEditingController();
  String? errorText;
  bool isAddButtonValid = false;

  /// 初期化処理
  Future<void> init() async {
    // ダミーデータを設定
    rankingList = ['サンプルランキング1', 'サンプルランキング2'];
    notifyListeners();
  }

  /// ランキング名のバリデーション。
  void validateRankingName(String value) {
    if (value.trim().isEmpty) {
      errorText = 'ランキング名を入力してください。';
      isAddButtonValid = false;
    } else if (value.trim().length > 20) {
      errorText = '20字以内で入力してください。';
      isAddButtonValid = false;
    } else {
      errorText = null;
      isAddButtonValid = true;
    }
    notifyListeners();
  }

  /// ランキングを追加
  Future<void> createRanking() async {
    final rankingName = rankingController.text.trim();
    if (rankingName.isEmpty || rankingList == null) return;

    // ローディング開始
    isLoading = true;
    notifyListeners();

    try {
      // ランキングリストに追加
      rankingList!.add(rankingName);

      // 入力フィールドをリセット
      rankingController.clear();
      validateRankingName('');

      // 成功メッセージ（コンソール出力）
      print('$rankingName を追加しました');
    } catch (e) {
      // エラーメッセージ（例外処理の追加）
      print('ランキング追加中にエラーが発生しました: $e');
    } finally {
      // ローディング終了
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    rankingController.dispose();
    super.dispose();
  }
}
