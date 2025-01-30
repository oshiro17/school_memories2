import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/class_model.dart';
import 'package:school_memories2/pages/each_profile.dart';
import 'package:school_memories2/pages/members_profile_model.dart';

// メンバー一覧表示ページ
class ProfilePage extends StatelessWidget {
  final ClassModel classInfo;
  const ProfilePage({Key? key, required this.classInfo}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final membersModel = context.watch<MembersProfileModel>();

    // 初回 (または forceUpdate 時) にfetch
    if (!membersModel.isFetched && !membersModel.isLoading) {
      membersModel.fetchClassMembers(classInfo.id);
    }

    return Scaffold(
      // 背景にグラデーションを適用
      body: Container(
        decoration: _buildBackgroundGradient(),
        child: SafeArea(
          child: membersModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : membersModel.classMemberList.isEmpty
                  ? const Center(child: Text('メンバーがいません'))
                  : Column(
                      children: [
                        const SizedBox(height: 16),
                        // 上部に角丸コンテナで classInfo.name を表示
                        _buildClassNameContainer(context),
                        const SizedBox(height: 24),
                        // 下部: 横スワイプできるカード一覧
                        Expanded(
                          child: PageView.builder(
                            controller: PageController(viewportFraction: 0.85),
                            scrollDirection: Axis.horizontal,
                            itemCount: membersModel.classMemberList.length,
                            itemBuilder: (context, index) {
                              final m = membersModel.classMemberList[index];
                              return _buildMemberCard(context, m);
                            },
                          ),
                        ),
                      ],
                    ),
        ),
      ),

      // ★ FloatingActionButton (リロードボタン) は変更しない
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF9ADBF0),
        onPressed: () async {
          // 強制リロード
          await membersModel.fetchClassMembers(classInfo.id, forceUpdate: true);
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  /// classInfo.name を角丸コンテナで表示
  Widget _buildClassNameContainer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        classInfo.name,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  /// メンバー情報をカード表示 (横スワイプするための子Widget)
  ///  - Columnで: 画像, 名前, motto, futureDream を縦に並べる
  Widget _buildMemberCard(BuildContext context, Member member) {
    return GestureDetector(
      onTap: () {
        // カードをタップすると EachProfilePage へ遷移
        // member.id を引数として渡す
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => EachProfilePage(memberId: member.id),
        //   ),
        // );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
        padding: const EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width * 0.78,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.90),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5.0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1) 画像
            ClipRRect(
              borderRadius: BorderRadius.circular(100), // 丸く切り抜き
              child: Image.asset(
                'assets/j${member.avatarIndex}.png', // avatarIndexを使う
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // 2) 名前
            Text(
              member.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 12),

            // 3) motto
            Text(
              member.motto.isNotEmpty ? member.motto : 'motto未設定',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // 4) futureDream
            Text(
              member.futureDream.isNotEmpty ? member.futureDream : '夢未設定',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
