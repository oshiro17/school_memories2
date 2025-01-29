import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/pages/each_profile.dart';
import 'members_profile_model.dart';

// メンバー一覧表示ページ
class ProfilePage extends StatelessWidget {
  final String classId;

  const ProfilePage({Key? key, required this.classId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MembersProfileModel()..fetchClassMembers(classId),
      child: Scaffold(
        body: Consumer<MembersProfileModel>(
          builder: (context, model, child) {
            if (model.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final classMemberList = model.classMemberList;

            // 全体をグラデーション背景にする
            return Container(
              decoration: _buildBackgroundGradient(),
              child: classMemberList.isEmpty
                  ? const Center(
                      child: Text(
                        'まだプロフィールがありません🥺',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    )
                  : PageView.builder(
                      itemCount: classMemberList.length,
                      controller: PageController(viewportFraction: 0.85),
                      itemBuilder: (context, index) {
                        final member = classMemberList[index];
                        return GestureDetector(
                          onTap: () {
                            // カードをタップしたら、それぞれのメンバーページ(EachProfilePage)へ遷移
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EachProfilePage(member: member),
                              ),
                            );
                          },
                          child: _buildMemberCard(member),
                        );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }

  /// 背景のグラデーション
  BoxDecoration _buildBackgroundGradient() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFFE0F7FA), // very light cyan
          Color(0xFFFFEBEE), // very light pink
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  /// メンバー情報をカード表示
  ///  - 上: 左上にクラスID
  ///  - 中: 左に太字で motto, 右にアイコン
  ///  - 下: 左に futureDream, 右下に "- name -"
  Widget _buildMemberCard(Member member) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90), // 背景を少し透明にしグラデを透かす
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      // Positioned等を使いたい場合はStackで包むと柔軟ですが、
      // 今回は単純なColumn配置の中に上部だけPositioned風に作ります
      child: Stack(
        children: [
          // 左上に classId を表示
          Positioned(
            top: 8,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.7),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                classId,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // カード本体の内容
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 36, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // (1) motto + アイコン
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // motto
                    Expanded(
                      child: Text(
                        member.birthday,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    // 右側にアイコン
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.orangeAccent,
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // (2) futureDream + name右下
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // futureDream（左寄せ, 幅調整のためExpandedで包むと良い）
                    Expanded(
                      child: Text(
                        member.subject,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    // 右下に - name -
                    Text(
                      '- ${member.name} -',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
