import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'vote_model.dart';

class VoteRankingPage extends StatelessWidget {
  VoteRankingPage({
    required this.classId,
    this.rankingList,
  });

  final String classId;
  final List<String>? rankingList;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'ランキングに投票する',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 4.0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_outlined,
              color: Colors.blue,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: ChangeNotifierProvider<VoteRankingPageModel>(
          create: (_) => VoteRankingPageModel(
            classId: classId,
            rankingList: rankingList,
          )..init(),
          child: Consumer<VoteRankingPageModel>(
            builder: (context, model, child) {
              final voteRankingCardList = model.rankingList?.map((ranking) {
                return _voteRankingCard(
                  title: ranking,
                  onTap: () {
                    // ダミーのタップアクション
                    print('$rankingが選択されました');
                  },
                );
              }).toList();

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: voteRankingCardList?.length ?? 0,
                      itemBuilder: (context, index) {
                        return voteRankingCardList![index];
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            controller: model.rankingController,
                            onChanged: model.validateRankingName,
                            decoration: InputDecoration(
                              labelText: 'ランキングを追加',
                              hintText: '例: 将来、オリンピックに出てそうな人',
                              errorText: model.errorText,
                              filled: true,
                              fillColor: Colors.blue.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: model.isAddButtonValid
                            ? () async {
                                try {
                                  // `createRanking`を呼び出す
                                  await model.createRanking();
                                  // UIを更新
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('ランキングを追加しました！'),
                                    ),
                                  );
                                } catch (e) {
                                  // エラーを表示
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('エラー: $e'),
                                    ),
                                  );
                                }
                              }
                            : null,
                        child: Text(
                          '追加',
                          style: TextStyle(
                            color: model.isAddButtonValid
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _voteRankingCard({
    required String title,
    required GestureTapCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
