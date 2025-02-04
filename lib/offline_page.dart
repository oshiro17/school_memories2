import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:school_memories2/offline_page.dart';
import 'package:school_memories2/pages/home.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget onlineChild;
  final Widget offlineChild;

  const ConnectivityWrapper({
    Key? key,
    required this.onlineChild,
    required this.offlineChild,
  }) : super(key: key);

  @override
  _ConnectivityWrapperState createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool isOnline = true;
  late final Stream<List<ConnectivityResult>> _connectivityStream;

@override
void initState() {
  super.initState();
  _connectivityStream = Connectivity().onConnectivityChanged;
  _connectivityStream.listen((results) {
    // results は List<ConnectivityResult> です。
    // 例えば、最初の要素を利用する場合:
    if (results.isNotEmpty) {
      setState(() {
        isOnline = (results.first != ConnectivityResult.none);
      });
    }
  });
}
  @override
  Widget build(BuildContext context) {
    return isOnline ? widget.onlineChild : widget.offlineChild;
  }
}

// グローバルに navigatorKey を定義
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class OfflinePage extends StatefulWidget {
  final String error;
  const OfflinePage({Key? key, required this.error}) : super(key: key);

  @override
  _OfflinePageState createState() => _OfflinePageState();
}

class _OfflinePageState extends State<OfflinePage> {
  late StreamSubscription<ConnectivityResult> _subscription;

  @override
  void initState() {
    super.initState();

    // Connectivity().onConnectivityChanged のストリームから先頭の結果だけ取り出す
    _subscription = Connectivity()
        .onConnectivityChanged
        .map((results) => results.first)
        .listen((result) {
      if (result != ConnectivityResult.none) {
        // 戻る先があるなら pop()、なければホーム画面へ遷移
        if (navigatorKey.currentState != null &&
            navigatorKey.currentState!.canPop()) {
          navigatorKey.currentState!.pop();
         }
        // else {
        //   navigatorKey.currentState?.pushReplacement(
        //     MaterialPageRoute(builder: (_) => HomeScreen()),
        //   );
        // }
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'エラー',
      navigatorKey: navigatorKey, // グローバルな navigatorKey を設定
      home: Scaffold(
        appBar: AppBar(
          title: const Text('エラー'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'オフラインです。又はエラーが発生しました。\nアプリを閉じて再度立ち上げてください。',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Colors.red),
                ),
                const SizedBox(height: 20),
                Text(
                  'エラー詳細: ${widget.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
