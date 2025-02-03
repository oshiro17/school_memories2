// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';

// /// インターネット接続状況を確認します。
// Future<bool> checkConnectivity() async {
//   final connectivityResult = await Connectivity().checkConnectivity();
//   return connectivityResult != ConnectivityResult.none;
// }

// /// Firebase の操作を安全に実行するための関数です。
// /// 1. ネットワークがなければ例外を投げる
// /// 2. 40秒以上処理がかかる場合はタイムアウトとして例外を投げる
// /// 3. Firebase 由来のエラーやその他のエラーもキャッチし、ユーザーに優しいメッセージに変換する
// Future<T> safeFirebaseCall<T>(Future<T> Function() firebaseCall) async {
//   // ネットワーク接続チェック
//   if (!await checkConnectivity()) {
//     throw Exception("インターネットに接続されていません。ネットワーク設定を確認してください。");
//   }
//   try {
//     // firebaseCall を 40秒以内に完了させる
//     return await firebaseCall().timeout(
//       const Duration(seconds: 40),
//       onTimeout: () {
//         throw TimeoutException("処理が40秒以上かかっています。再試行してください。");
//       },
//     );
//   } on FirebaseException catch (e) {
//     // Firebase固有のエラーの場合
//     print("Firebaseエラー: ${e.message}");
//     throw Exception("サーバーとの通信に問題があります。しばらくしてから再試行してください。");
//   } catch (e) {
//     // その他の例外の場合
//     print("エラー: $e");
//     throw Exception("データの取得に失敗しました。再試行してください。");
//   }
// }
