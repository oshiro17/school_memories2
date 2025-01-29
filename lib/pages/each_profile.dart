import 'package:flutter/material.dart';
import 'package:school_memories2/pages/members_profile_model.dart';

class EachProfilePage extends StatelessWidget {
  final Member member;

  const EachProfilePage({Key? key, required this.member}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // member.name, member.birthday, member.motto, ...などを表示
    return Scaffold(
      appBar: AppBar(
        title: Text(member.name), 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Futu'),
      ),
    );
  }
}
