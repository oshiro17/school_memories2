import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/color.dart';
import 'package:school_memories2/pages/message.dart';
import 'package:school_memories2/pages/ranking_page_model.dart';

class RankingPage extends StatelessWidget {
  final String classId;
  final String currentMemberId;

  const RankingPage({
    Key? key,
    required this.classId,
    required this.currentMemberId,
  }) : super(key: key);

 @override
  Widget build(BuildContext context) {
    // Connectivity のストリームから、リストが空の場合は ConnectivityResult.none を返すように防御的記述
    final connectivityStream = Connectivity().onConnectivityChanged.map(
      (results) => results.isNotEmpty ? results.first : ConnectivityResult.none,
    );

    return StreamBuilder<ConnectivityResult>(
      stream: Connectivity().onConnectivityChanged.map(
  (results) => results.isNotEmpty ? results.first : ConnectivityResult.none,
),
      builder: (context, snapshot) {
        // snapshot.data が null の場合は ConnectivityResult.none とする
        final connectivityResult = snapshot.data ?? ConnectivityResult.none;
        final offline = connectivityResult == ConnectivityResult.none;

        return Consumer<RankingPageModel>(
          builder: (context, model, child) {
            return Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFE0F7FA), // very light cyan
                      Color(0xFFFFEBEE), // very light pink
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: _buildBodyContent(model),
              ),
              floatingActionButton: StreamBuilder<ConnectivityResult>(
  // 最新の connectivity_plus では、直接 ConnectivityResult を返す
  stream: Connectivity().onConnectivityChanged.map(
    (results) => results.isNotEmpty ? results.first : ConnectivityResult.none,
  ),
  builder: (context, snapshot) {
    // snapshot.data が null の場合はオンライン状態（例: ConnectivityResult.mobile）と仮定する
    final connectivityResult = snapshot.data ?? ConnectivityResult.mobile;
    // オフラインならば、ConnectivityResult.none になるはず
    final bool offline = connectivityResult == ConnectivityResult.none;
    
    // デバッグ用に現在の接続状態を出力
    // print("Current connectivity: $connectivityResult");

    return FloatingActionButton(
      backgroundColor: offline ? Colors.grey : goldColor,
      // オフラインの場合は onPressed を null にして無効化、オンラインの場合のみ有効
      onPressed: offline
          ? null
          : () {
              Provider.of<MessageModel>(context, listen: false)
                  .fetchMessages(classId, currentMemberId, forceUpdate: true);
            },
      child: const Icon(Icons.refresh),
    );
  },
),
              // floatingActionButton: FloatingActionButton(
              //  backgroundColor: offline ? Colors.grey : goldColor,
              //   // オフラインの場合は onPressed を null にしてボタンを無効化
              //   onPressed: offline
              //       ? null
              //       : () {
              //           // forceUpdate = true => キャッシュ無視して再読み込み
              //           model.init(classId, currentMemberId, forceUpdate: true);
              //         },
              //   child: const Icon(Icons.refresh),
              // ),
            );
          },
        );
      },
    );
  }
  /// メインの表示ロジック
  Widget _buildBodyContent(RankingPageModel model) {
    // エラー状態がある場合はエラーメッセージと再試行ボタンを表示
    if (model.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                model.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // 再試行（forceUpdate: true で再読み込み）
                  model.init(classId, currentMemberId, forceUpdate: true);
                },
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      );
    }

    // 1) 全体ロード中
    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2) まだ投票していない
    if (!model.isVoted) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
          child: Text(
            'ランキングはまだ見れません\n投票してください。',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      );
    }

    // 3) 投票済みなら ListView で順次表示
    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: model.questionList.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          // 先頭にAppBar分の余白用
          return const SizedBox(height: kToolbarHeight + 12);
        }
        return _buildRankingCard(context, model, index - 1);
      },
    );
  }

  /// 質問ごとのランキングカード
  Widget _buildRankingCard(BuildContext context, RankingPageModel model, int index) {
    final question = model.questionList[index];
    final votes = model.rankingVotes[index]; // null=ロード中, []=投票なし, list=取得完了

    // votes が null => ロード中
    // votes が空 => 投票なし
    // votes が要素あり => 表示
    final topVotes = votes?.take(3).toList() ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 質問タイトル
            Text(
              question,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkBlueColor,
              ),
            ),
            const SizedBox(height: 16),
            if (votes == null)
              // ロード中
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (topVotes.isEmpty)
              // 投票なし
              const Text(
                'まだ投票がありません。',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              )
            else
              // 上位3名のリスト
              ...topVotes.asMap().entries.map((entry) {
                final rank = entry.key; // 0=1位,1=2位,2=3位
                final vote = entry.value;
                return ListTile(
                  leading: SizedBox(
                    width: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // avatar画像
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: AssetImage('assets/j${vote.avatarIndex}.png'),
                        ),
                        // 王冠と順位
                        Positioned(
                          top: -2,
                          left: -4,
                          child: _buildCrownWithRank(rank),
                        ),
                      ],
                    ),
                  ),
                  title: Text(
                    vote.memberName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '${vote.count}票',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  /// 王冠と順位を表示するウィジェット
  Widget _buildCrownWithRank(int rank) {
    late Color crownColor;
    switch (rank) {
      case 0:
        crownColor = Colors.amber;  // 金
        break;
      case 1:
        crownColor = Colors.grey;   // 銀
        break;
      case 2:
        crownColor = Colors.brown;  // 銅
        break;
      default:
        return const SizedBox.shrink();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.emoji_events,
          color: crownColor,
          size: 35,
        ),
        Positioned(
          top: 4,
          child: Text(
            '${rank + 1}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
