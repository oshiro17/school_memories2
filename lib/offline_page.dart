import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class OfflinePage extends StatelessWidget {
  final String error;

  const OfflinePage({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'エラー',
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
                  'オフラインです。\nアプリを閉じてください。',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Colors.red),
                ),
                const SizedBox(height: 20),
                Text(
                  'エラー詳細: $error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: const Text('閉じる'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
