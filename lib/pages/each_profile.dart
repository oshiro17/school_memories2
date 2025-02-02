
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/pages/each_profile_model.dart';

// /// ラベルと値を表示する共通Widget
  Widget _buildProfileItem2(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),

  
        Expanded(
          child:  Text(
          '$value',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        ),

      ],
    );
  }
  Widget _buildProfileItem(String label, String value, String label2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
          
         Text(
            value.isNotEmpty ? value : '未設定',
            style: const TextStyle(fontSize: 16, color: Colors.blue),

          ),
  
        Expanded(
          child:  Text(
          '$label2',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        ),

      ],
    );
  }
 Widget _buildProfileField(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }

Widget _buildSection(List<Widget> children) {
  return Container(
    width: double.infinity, // 横幅いっぱいにする
    margin: EdgeInsets.symmetric(vertical: 10), // 横のマージンをなくす
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

Widget _buildProfileText(String label, String value, {bool isCallMe = false}) {
    return Text.rich(
      TextSpan(
        children: [
          if (!isCallMe) TextSpan(text: label, style: TextStyle(color: Colors.black,fontSize: 16)),
          TextSpan(text: value, style: TextStyle(color: Colors.blue,fontSize: 17)), // 青色
          if (!isCallMe) TextSpan(text: ' だよ', style: TextStyle(color: Colors.black,fontSize: 16)),
          if (isCallMe) TextSpan(text: ' って呼んで！', style: TextStyle(color: Colors.black)),
        ],
      ),
    );
  }


class EachProfilePage extends StatelessWidget {
  final String classId;
  final String memberId;

  const EachProfilePage({Key? key, required this.memberId, required this.classId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EachProfileModel>(
      // モデルを生成して、memberId,classIdに基づくfetchを開始
      create: (_) => EachProfileModel()..fetchProfile(memberId,classId),
      child: Consumer<EachProfileModel>(
        builder: (context, model, child) {
          // ローディング中
          if (model.isLoading) {
            return Scaffold(
              extendBodyBehindAppBar: true, 
              appBar: AppBar(
  backgroundColor: Colors.white.withOpacity(0.5),
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () => Navigator.pop(context),
  ),
),

              
              body: Center(child: CircularProgressIndicator()),
            );
          }
            final avatarPath = 'assets/j${model.avatarIndex}.png';

          // 画面描画（質問者さんの記述したUIに合わせて使用）
          // 例: 各フィールドを表示
 return Scaffold(
  appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () => Navigator.pop(context),
  ),
),

      body: 
 SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

Row(
  crossAxisAlignment: CrossAxisAlignment.end,
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Padding(
      padding: const EdgeInsets.only(top: 24.0, left: 8.0, right: 8.0),
      child: CircleAvatar(
        radius: 50,
        backgroundImage: AssetImage(avatarPath),
      ),
    ),
    const SizedBox(width: 16),
    Text(
      
      model.name,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    ),
  ],
),
                  const SizedBox(height: 16),
                  // プロフィール詳細
           Center(
  child: Column(
    mainAxisSize: MainAxisSize.min, // 必要な分だけ高さを確保
    crossAxisAlignment: CrossAxisAlignment.center, // 横方向の中央揃え
 children: [
_buildProfileText('こんにちは ', model.name),
_buildProfileText('', model.q1, isCallMe: true),
_buildProfileText('星座は', model.q2),
_buildProfileText('好きな教科は ', model.q3),
_buildProfileText('私を一言で表すと ', model.q4),
_buildProfileText('身長は今, ', model.q5),
_buildProfileText('MBTIは ', model.q6),
],
  ),
),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection([
     _buildProfileField('趣味特技', model.q7),
        _buildProfileField('部活', model.q8),
        _buildProfileField('なりたい職業', model.q9),
        _buildProfileField('好きな歌', model.q10),
        _buildProfileField('好きな映画', model.q11),
        _buildProfileField('好きな人', model.q12),
        _buildProfileField('好きなタイプ', model.q13),
        _buildProfileField('たからもの', model.q14),
        _buildProfileField('最近ゲットした一番高いもの', model.q15),
        _buildProfileField('今一番欲しいもの', model.q16),
        _buildProfileField('好きな場所', model.q17),
]),

_buildSection([
    _buildProfileField('最近の事件は？', model.q18),
        _buildProfileField('きのう、何した？', model.q19),
        _buildProfileField('学校生活で達成した一番の偉業は？', model.q20),
]),

_buildSection([
      _buildProfileField('長所', model.q21),
        _buildProfileField('短所', model.q22),
]),

_buildSection([
  _buildProfileField('1億あったら何したい？', model.q23),
        _buildProfileField('尊敬している人は誰？', model.q24),
        _buildProfileField('10年後自分は何してると思う？', model.q25),
        _buildProfileField('明日の目標は？', model.q26),
        _buildProfileField('叶えたい夢は？', model.q27),]),

_buildSection([
        _buildProfileField('みんなへメッセージ', model.q28),
        _buildProfileField('座右の銘', model.q29),
]),

        
        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
 ),
            );
        },
      ),
    );
  }
}
