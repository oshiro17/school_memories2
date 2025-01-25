// class_list_page_model.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../class_model.dart';

class ClassListPageModel extends ChangeNotifier {
  bool isLoading = false;
  List<ClassModel> joinedClasses = [];

  Future<void> fetchAttendingClasses() async {
    isLoading = true;
    notifyListeners();

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('attendingClasses')
          .get();

      final List<ClassModel> list = [];
      for (var doc in snap.docs) {
        final classId = doc.id;
        // classes/{classId} を取得して ClassModel に変換
        final classDoc = await FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .get();
        if (!classDoc.exists) {
          continue;
        }
        final data = classDoc.data()!;
        list.add(ClassModel.fromMap(data));
      }
      joinedClasses = list;
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 参加済クラスのパスワードをチェックする
  /// パスワードが正しければ OK、違えば Exception を投げる
  Future<void> checkPasswordAndEnter(ClassModel classModel, String inputPass) async {
    // Firestore から最新のクラス情報を取ってくる
    final doc = await FirebaseFirestore.instance
        .collection('classes')
        .doc(classModel.id)
        .get();
    if (!doc.exists) {
      throw 'クラス情報が存在しません。';
    }
    final data = doc.data()!;
    final realPass = data['password'] ?? '';
    if (realPass != inputPass) {
      throw 'パスワードが違います。';
    }
  }
}
