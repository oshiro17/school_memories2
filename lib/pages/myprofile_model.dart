import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyProfileModel extends ChangeNotifier {
String callme = '';
  String name = '';
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
  String futureMessage = '';
  String futureSelf = '';
  String goal = '';
  String futureDream = '';
  String motto = '';
    int avatarIndex = 0;
  bool isLoading = false;

  // プロフィールを一度取得したら true にする


  Future<void> fetchProfileOnce(String classId, String memberId) async {

    try {
      isLoading = true;
      notifyListeners();

      // ここで1回だけ Firestoreから取得
      final doc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(memberId)
          .get();

      if (doc.exists) {
   final data = doc.data();
callme = data?['callme'] ?? '';
name = data?['name'] ?? '';
birthday = data?['birthday'] ?? '';
subject = data?['subject'] ?? '';
bloodType = data?['bloodType'] ?? '';
height = data?['height'] ?? '';
mbti = data?['mbti'] ?? '';
hobby = data?['hobby'] ?? '';
club = data?['club'] ?? '';
dream = data?['dream'] ?? '';
favoriteSong = data?['favoriteSong'] ?? '';
favoritePerson = data?['favoritePerson'] ?? '';
treasure = data?['treasure'] ?? '';
recentEvent = data?['recentEvent'] ?? '';
schoolLife = data?['schoolLife'] ?? '';
achievement = data?['achievement'] ?? '';
strength = data?['strength'] ?? '';
weakness = data?['weakness'] ?? '';
futurePlan = data?['futurePlan'] ?? '';
lifeStory = data?['lifeStory'] ?? '';
futureMessage = data?['futureMessage'] ?? '';
futureSelf = data?['futureSelf'] ?? '';
goal = data?['goal'] ?? '';
futureDream = data?['futureDream'] ?? '';
motto = data?['motto'] ?? '';

        avatarIndex = data?['avatarIndex'] ?? 0;
      }

    } catch (e) {
      print('fetchProfileエラー: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
   Future<void> init(String classId, String memberId) async {
    await fetchProfileOnce(classId, memberId);
  }

}
