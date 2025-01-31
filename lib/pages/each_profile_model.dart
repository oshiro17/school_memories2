import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EachProfileModel extends ChangeNotifier {
  bool isLoading = false;

  // Firestoreから取得したいデータをフィールドとして定義
  int avatarIndex = 0;
  String name = '';
  String callme = '';
  String birthday = '';
  String subject = '';
  String bloodType = '';
  String height = '';
  String mbti = '';
  String hobby = '';
  String club = '';
  String dream = '';
  String favoriteSong = '';
  String favoritePerson = '';
  String treasure = '';
  String recentEvent = '';
  String schoolLife = '';
  String achievement = '';
  String strength = '';
  String weakness = '';
  String futurePlan = '';
  String lifeStory = '';
  String futureSelf = '';
  String futureMessage = '';
  String goal = '';
  String futureDream = '';
  String motto = '';

  /// Firestoreから [memberID] に対応するメンバー情報を取得
  Future<void> fetchProfile(String memberID ,String classId) async {
    isLoading = true;
    notifyListeners();
    // print(classId);

    try {
 final doc = await FirebaseFirestore.instance
    .collection('classes')
    .doc(classId)
    .collection('members')
    .doc(memberID)
    .get();


      if (doc.exists) {
        final data = doc.data() ?? {};

        // それぞれのフィールドに代入
        avatarIndex = data['avatarIndex'] ?? 0;
        name = data['name'] ?? '';
        callme = data['callme'] ?? '';
        birthday = data['birthday'] ?? '';
        subject = data['subject'] ?? '';
        bloodType = data['bloodType'] ?? '';
        height = data['height'] ?? '';
        mbti = data['mbti'] ?? '';
        hobby = data['hobby'] ?? '';
        club = data['club'] ?? '';
        dream = data['dream'] ?? '';
        favoriteSong = data['favoriteSong'] ?? '';
        favoritePerson = data['favoritePerson'] ?? '';
        treasure = data['treasure'] ?? '';
        recentEvent = data['recentEvent'] ?? '';
        schoolLife = data['schoolLife'] ?? '';
        achievement = data['achievement'] ?? '';
        strength = data['strength'] ?? '';
        weakness = data['weakness'] ?? '';
        futurePlan = data['futurePlan'] ?? '';
        lifeStory = data['lifeStory'] ?? '';
        futureSelf = data['futureSelf'] ?? '';
        futureMessage = data['futureMessage'] ?? '';
        goal = data['goal'] ?? '';
        futureDream = data['futureDream'] ?? '';
        motto = data['motto'] ?? '';
      }
    } catch (e) {
      debugPrint('fetchProfileエラー: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
