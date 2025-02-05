import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:school_memories2/class_model.dart';
import 'package:school_memories2/color.dart';
import 'package:school_memories2/main.dart'; // navigatorKey が定義されているファイル

class SettingProfileModel extends ChangeNotifier {
  bool isLoading = false;
  
  /// Firestoreへプロフィールを保存する
  Future<void> saveProfile({
    required String q1,
    required String q2,
    required String q3,
    required String q4,
    required String q5,
    required String q6,
    required String q7,
    required String q8,
    required String q9,
    required String q10,
    required String q11,
    required String q12,
    required String q13,
    required String q14,
    required String q15,
    required String q16,
    required String q17,
    required String q18,
    required String q19,
    required String q20,
    required String q21,
    required String q22,
    required String q23,
    required String q24,
    required String q25,
    required String q26,
    required String q27,
    required String q28,
    required String q29,
    required String q30,
    required String q31,
    required String q32,
    required String q33,
    required String classId,
    required String memberId,
    required int avatarIndex,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final memberData = {
        'q1':  q1,
        'q2':  q2,
        'q3':  q3,
        'q4':  q4,
        'q5':  q5,
        'q6':  q6,
        'q7':  q7,
        'q8':  q8,
        'q9':  q9,
        'q10': q10,
        'q11': q11,
        'q12': q12,
        'q13': q13,
        'q14': q14,
        'q15': q15,
        'q16': q16,
        'q17': q17,
        'q18': q18,
        'q19': q19,
        'q20': q20,
        'q21': q21,
        'q22': q22,
        'q23': q23,
        'q24': q24,
        'q25': q25,
        'q26': q26,
        'q27': q27,
        'q28': q28,
        'q29': q29,
        'q30': q30,
        'q31': q31,
        'q32': q32,
        'q33': q33,
        'avatarIndex': avatarIndex,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(memberId)
          .set(memberData, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        // ネットワークエラーの場合、OfflinePage へ遷移
        // ここにオフライン時の処理を記述することも可能です。
      } else {
        rethrow;
      }
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}