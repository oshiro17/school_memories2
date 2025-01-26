// class_selection_page_model.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../class_model.dart';

class ClassSelectionPageModel extends ChangeNotifier {
  // クラス作成用
  final classNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  // クラス参加用
  final classNumberForJoinController = TextEditingController();
  final passwordForJoinController = TextEditingController();

  /// 新規クラスを作成して、FireStore に保存 + 自分をメンバー登録
  /// 成功時には作成したクラスの ClassModel を返す
  Future<ClassModel> createClass() async {
    final classNumber = classNumberController.text.trim();
    final password = passwordController.text.trim();
    final className = nameController.text.trim();

    if (classNumber.isEmpty || password.isEmpty || className.isEmpty) {
      throw '入力されていない項目があります。';
    }

    // 既に同じ classNumber が使われていないかチェック
    final exists = await FirebaseFirestore.instance
        .collection('classes')
        .where('classNumber', isEqualTo: classNumber)
        .limit(1)
        .get();
    if (exists.docs.isNotEmpty) {
      // 同じクラスIDが存在する
      throw 'クラスID "$classNumber" は既に使われています。';
    }

    // 新しいクラスを作成
    final classesRef = FirebaseFirestore.instance.collection('classes');
    final newClassDoc = classesRef.doc(); // docId 自動生成
    final docId = newClassDoc.id;

    final now = Timestamp.now();
    final classData = {
      'id': docId,
      'classNumber': classNumber,
      'password': password, // 平文で保存（セキュリティルールは省略）
      'name': className,
      'userCount': 1,
      'createdAt': now,
      'updatedAt': now,
    };

    // 書き込み
    await newClassDoc.set(classData);

    // members サブコレクションに自分を登録
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final userData = userDoc.data() ?? {};

    final memberData = {
      'id': uid,
      'classId': docId,
      'name': userData['name'] ?? '',
      'subject': userData['subject'] ?? '',
      'birthday': userData['birthday'] ?? '',
      'joinedAt': now,
    };
    await newClassDoc.collection('members').doc(uid).set(memberData);

    // ユーザーの attendingClasses にも追加
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('attendingClasses')
        .doc(docId)
        .set({
      'id': docId,
      'createdAt': now,
      'updatedAt': now,
    });

    // 最後に ClassModel を返す
    return ClassModel.fromMap(classData);
  }

  /// 既存クラスに参加する
  /// 成功時には参加したクラスの ClassModel を返す
  Future<ClassModel> joinClass() async {
    final classNumber = classNumberForJoinController.text.trim();
    final password = passwordForJoinController.text.trim();
    if (classNumber.isEmpty || password.isEmpty) {
      throw 'クラスID と パスワードを入力してください。';
    }

    // classNumber が一致するクラスを取得
    final snap = await FirebaseFirestore.instance
        .collection('classes')
        .where('classNumber', isEqualTo: classNumber)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) {
      throw 'クラスが存在しません。';
    }
    final classDoc = snap.docs.first;
    final classData = classDoc.data();
    final classId = classData['id'] as String;

    // パスワードチェック
    if (classData['password'] != password) {
      throw 'パスワードが違います。';
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;

    // 既に参加しているかどうかチェック
    final memberDoc = await FirebaseFirestore.instance
        .collection('classes')
        .doc(classId)
        .collection('members')
        .doc(uid)
        .get();
    if (memberDoc.exists) {
      throw '既に参加しています。';
    }

    // メンバー登録 + attendingClasses 登録 + userCount のインクリメント
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final userData = userDoc.data() ?? {};
    final now = Timestamp.now();

    // バッチ or トランザクションでまとめてもOK
    final batch = FirebaseFirestore.instance.batch();
    final classRef = FirebaseFirestore.instance.collection('classes').doc(classId);
    final membersRef = classRef.collection('members').doc(uid);
    final attendingRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('attendingClasses')
        .doc(classId);

    batch.set(membersRef, {
      'id': uid,
      'classId': classId,
      'name': userData['name'] ?? '',
      'birthday': userData['birthday'] ?? '',
      'subject': userData['subject'] ?? '',
      'joinedAt': now,
    });
    batch.set(attendingRef, {
      'id': classId,
      'createdAt': now,
      'updatedAt': now,
    });
    // userCount インクリメント
    final newCount = (classData['userCount'] ?? 0) + 1;
    batch.update(classRef, {
      'userCount': newCount,
      'updatedAt': now,
    });

    // コミット
    await batch.commit();

    // 参加したクラス情報を返す
    final updatedData = {
      ...classData,
      'userCount': newCount,
    };
    return ClassModel.fromMap(updatedData);
  }

  @override
  void dispose() {
    classNumberController.dispose();
    passwordController.dispose();
    nameController.dispose();
    classNumberForJoinController.dispose();
    passwordForJoinController.dispose();
    super.dispose();
  }
}
