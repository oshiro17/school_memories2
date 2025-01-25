import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyProfileModel extends ChangeNotifier {
  String name = '';
  String birthday = '';
  String subject = '';
bool isLoading = false;
  Future<void> init(BuildContext context) async {
    await fetchProfile();
  }

 Future<void> fetchProfile() async {
    try {
      isLoading = true;
      notifyListeners();

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        name = data?['name'] ?? '';
        birthday = data?['birthday'] ?? '';
        subject = data?['subject'] ?? '';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String name,
    required String birthday,
    required String subject,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('ログイン情報がありません');

    final data = {
      'name': name,
      'birthday': birthday,
      'subject': subject,
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));

    // モデルに即時反映
    this.name = name;
    this.birthday = birthday;
    this.subject = subject;
    notifyListeners();
  }
}
