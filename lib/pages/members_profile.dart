import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/class_model.dart';
import 'package:school_memories2/color.dart';
import 'package:school_memories2/pages/each_profile.dart';
import 'package:school_memories2/pages/members_profile_model.dart';

// メンバー一覧表示ページ
class ProfilePage extends StatelessWidget {
  final ClassModel classInfo;
  final String currentMemberId;
  const ProfilePage({Key? key, required this.classInfo, required this.currentMemberId}) : super(key: key);

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
    // if (!membersModel.isLoading) {
    //   membersModel.fetchClassMembers(classInfo.id,currentMemberId);
    // }

    return Scaffold(
  // 背景にグラデーションを適用
  body: Container(
    decoration: _buildBackgroundGradient(),
    child: SafeArea(
      child: membersModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : membersModel.isEmpty
              ? const Center(
                  child: Text(
                    'プロフィール設定をしないと見れません',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, ),
                    textAlign: TextAlign.center,
                  ),
                )
              : membersModel.classMemberList.isEmpty
                  ? const Center(child: Text('メンバーがいません'))
                  : Column(
                      children: [
                        const SizedBox(height: 16),
                        // 上部に角丸コンテナで classInfo.name を表示
                        _buildClassNameContainer(context),
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

      // ★ FloatingActionButton (リロードボタン) は変更しない
floatingActionButton: FloatingActionButton(
  backgroundColor: goldColor,
  onPressed: () async {
    // 強制リロード（Firestoreから再取得）
    await membersModel.fetchClassMembers(classInfo.id, currentMemberId, forceRefresh: true);
  },
  child: const Icon(Icons.refresh),
),

    );
  }

  /// classInfo.name を角丸コンテナで表示
Widget _buildClassNameContainer(BuildContext context) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 38), // 左に余白をつける
        child: Text(
          classInfo.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: darkBlueColor,
          ),
        ),
      ),
    ],
  );
}


  /// メンバー情報をカード表示 (横スワイプするための子Widget)
  ///  - Columnで: 画像, 名前, motto, futureDream を縦に並べる
  Widget _buildMemberCard(BuildContext context, Member member) {
    return GestureDetector(
      onTap: () {
        // カードをタップすると EachProfilePage へ遷移
        // member.id を引数として渡す
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EachProfilePage(memberId: member.id,classId: classInfo.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top:5, bottom: 25, left: 8, right: 8),
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
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            // 3) motto
            Text(
              member.motto.isNotEmpty ? member.motto : '',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // 4) futureDream
            Text(
              member.futureDream.isNotEmpty ? member.futureDream : '',
              style: const TextStyle(fontSize: 14, color: darkBlueColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
