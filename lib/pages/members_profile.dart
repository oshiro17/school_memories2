// profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/class_model.dart';
import 'package:school_memories2/color.dart';
import 'package:school_memories2/pages/members_profile.dart';
import 'package:school_memories2/pages/members_profile_model.dart';

class ProfilePage extends StatelessWidget {
  final ClassModel classInfo;
  final String currentMemberId;

  const ProfilePage({Key? key, required this.classInfo, required this.currentMemberId})
      : super(key: key);

  /// 背景グラデーション
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

    return Scaffold(
      body: Container(
        decoration: _buildBackgroundGradient(),
        child: SafeArea(
          child: membersModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : membersModel.errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            membersModel.errorMessage!,
                            style: const TextStyle(fontSize: 16, color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () async {
                              await membersModel.fetchClassMembers(
                                  classInfo.id, currentMemberId, forceRefresh: true);
                            },
                            child: const Text('再試行'),
                          ),
                        ],
                      ),
                    )
                  : membersModel.isEmpty || membersModel.classMemberList.isEmpty
                      ? const Center(
                          child: Text(
                            '表示するメンバーがありません',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Column(
                          children: [
                            const SizedBox(height: 16),
                            _buildClassNameContainer(),
                            Expanded(
                              child: PageView.builder(
                                controller: PageController(viewportFraction: 0.85),
                                scrollDirection: Axis.horizontal,
                                itemCount: membersModel.classMemberList.length,
                                itemBuilder: (context, index) {
                                  final member = membersModel.classMemberList[index];
                                  return _buildMemberCard(context, member);
                                },
                              ),
                            ),
                          ],
                        ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: goldColor,
        onPressed: () async {
          await membersModel.fetchClassMembers(classInfo.id, currentMemberId, forceRefresh: true);
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  /// 上部にクラス名を表示するウィジェット
  Widget _buildClassNameContainer() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 38),
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

  /// メンバー情報カード（固定高さ内で ListView により縦スクロール可能）
  Widget _buildMemberCard(BuildContext context, Member member) {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
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
        child: SizedBox(
          height: 200, // 固定の高さ
          child: ListView(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    'assets/j${member.avatarIndex}.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  member.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  member.motto,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  member.futureDream,
                  style: const TextStyle(fontSize: 14, color: darkBlueColor),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 15),
              // 以下、詳細プロフィール項目の表示例
              _buildProfileText('こんにちは ', member.name),
              _buildProfileText('', member.q1, isCallMe: true),
              _buildProfileText('星座は', member.q2),
              _buildProfileText('好きな教科は ', member.q3),
              _buildProfileText('私を一言で表すと ', member.q4),
              _buildProfileText('身長は今, ', member.q5),
              _buildProfileText('MBTIは ', member.q6),
              const SizedBox(height: 15),
              _buildProfileField('趣味特技', member.q7),
              _buildProfileField('部活', member.q8),
              _buildProfileField('なりたい職業', member.q9),
              _buildProfileField('好きな歌', member.q10),
              _buildProfileField('好きな映画', member.q11),
              _buildProfileField('好きな人', member.q12),
              _buildProfileField('好きなタイプ', member.q13),
              _buildProfileField('たからもの', member.q14),
              _buildProfileField('最近ゲットした一番高いもの', member.q15),
              _buildProfileField('今一番欲しいもの', member.q16),
              _buildProfileField('好きな場所', member.q17),
              const SizedBox(height: 15),
              _buildProfileField('最近の事件は？', member.q18),
              _buildProfileField('最近幸せだったこと', member.q30),
              _buildProfileField('最近きつかったこと', member.q31),
              _buildProfileField('最近面白かったこと', member.q32),
              _buildProfileField('最近泣いちゃったこと', member.q33),
              _buildProfileField('きのう、何した？', member.q19),
              _buildProfileField('今までで達成した一番の偉業は？', member.q20),
              const SizedBox(height: 15),
              _buildProfileField('長所', member.q21),
              _buildProfileField('短所', member.q22),
              const SizedBox(height: 15),
              _buildProfileField('1億あったら何したい？', member.q23),
              _buildProfileField('尊敬している人は誰？', member.q24),
              _buildProfileField('10年後自分は何してると思う？', member.q25),
              _buildProfileField('明日の目標は？', member.q26),
              _buildProfileField('叶えたい夢は？', member.q27),
            ],
          ),
        ),
      ),
    );
  }
}

/// 複数テキストスパンでリッチテキストを構築するユーティリティ
Widget _buildProfileText(String label, String value, {bool isCallMe = false}) {
  return Text.rich(
    TextSpan(
      children: [
        if (!isCallMe)
          TextSpan(
            text: label,
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
        TextSpan(
          text: value,
          style: const TextStyle(color: darkBlueColor, fontSize: 17),
        ),
        if (!isCallMe)
          const TextSpan(
            text: ' だよ',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        if (isCallMe)
          const TextSpan(
            text: ' って呼んで！',
            style: TextStyle(color: Colors.black),
          ),
      ],
    ),
  );
}

/// プロフィール項目表示用ウィジェット
Widget _buildProfileField(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkBlueColor),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
      ],
    ),
  );
}
