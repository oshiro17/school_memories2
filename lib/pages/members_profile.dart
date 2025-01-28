import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                        return _buildMemberCard(member);
                      },
                    ),
            );
          },
        ),
      ),
    );
  }

  // グラデーションの定義
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

  // メンバー情報をカード表示
  Widget _buildMemberCard(Member member) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85), // 背景を少し透明にしグラデをうっすら透過
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "名前: ${member.name}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("誕生日: ${member.birthday}"),
              const SizedBox(height: 8),
              Text("好きな教科: ${member.subject}"),
            ],
          ),
        ),
      ),
    );
  }
}
