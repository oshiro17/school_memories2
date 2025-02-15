import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BlockPage extends StatefulWidget {
  final String classId;
  final String currentMemberId;

  const BlockPage({
    Key? key,
    required this.classId,
    required this.currentMemberId,
  }) : super(key: key);

  @override
  State<BlockPage> createState() => _BlockPageState();
}

class _BlockPageState extends State<BlockPage> {
  bool isLoading = false;
  String? errorMessage;

  /// Firestore から取得した「自分の blockedList」
  List<String> blockedList = [];

  /// Firestore から取得した「クラス全メンバー」のリスト  
  ///   - 要素例: `{ "id": "xxx", "name": "yyy" }`
  List<Map<String, dynamic>> allMembers = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  /// 初期データをまとめて取得
  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      // 自分の memberDoc を取得して blockedList を取り出す
      final myDocRef = FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('members')
          .doc(widget.currentMemberId);

      final myDocSnap = await myDocRef.get();
      if (!myDocSnap.exists) {
        throw 'ログインユーザーのドキュメントが見つかりません。';
      }
      final myData = myDocSnap.data()!;
      final list = myData['blockedList'] as List<dynamic>?; // null の可能性
      blockedList = list?.map((e) => e.toString()).toList() ?? [];

      // クラス全体のメンバーを取得
      final snapshot = await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('members')
          .get();
      allMembers = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'NoName',
        };
      }).toList();

    } catch (e) {
      errorMessage = 'ブロック情報の取得に失敗しました: $e';
    } finally {
      isLoading = false;
      setState(() {});
    }
  }

  /// ユーザーをブロック解除
  Future<void> _unblockUser(String targetMemberId) async {
    setState(() => isLoading = true);
    try {
      final myDocRef = FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('members')
          .doc(widget.currentMemberId);

      await myDocRef.update({
        'blockedList': FieldValue.arrayRemove([targetMemberId])
      });
      blockedList.remove(targetMemberId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ブロックを解除しました。')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ブロック解除に失敗しました: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ブロックする人を追加
  /// - モーダル（showDialogなど）で「未ブロックメンバー一覧」を表示して選択
  void _showAddBlockDialog() {
    // 既に blockedList に含まれているIDは除外
    final nonBlockedMembers = allMembers
        .where((m) => m['id'] != widget.currentMemberId) // 自分を除外
        .where((m) => !blockedList.contains(m['id']))    // 既ブロックを除外
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ブロックするメンバーを選択'),
          content: SizedBox(
            width: double.maxFinite,
            child: nonBlockedMembers.isEmpty
                ? const Text('ブロックできるメンバーはいません。')
                : ListView.builder(
                    itemCount: nonBlockedMembers.length,
                    itemBuilder: (context, index) {
                      final m = nonBlockedMembers[index];
                      return ListTile(
                        title: Text(m['name']),
                        onTap: () {
                          Navigator.pop(context); // ダイアログを閉じる
                          _blockUser(m['id']);
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  /// ブロック実行
  Future<void> _blockUser(String targetMemberId) async {
    setState(() => isLoading = true);
    try {
      final myDocRef = FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('members')
          .doc(widget.currentMemberId);

      await myDocRef.update({
        'blockedList': FieldValue.arrayUnion([targetMemberId])
      });
      blockedList.add(targetMemberId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ブロックしました。')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ブロックに失敗しました: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final blockedMembers = allMembers
        .where((m) => blockedList.contains(m['id']))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ブロック管理'),
      ),
      body: Stack(
        children: [
          if (isLoading)
            const Center(child: CircularProgressIndicator()),

          if (!isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (errorMessage != null) ...[
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                  ],
                  // --- ブロック中のユーザー一覧 ---
                  Text(
                    '今ブロックしている人一覧',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: blockedMembers.isEmpty
                        ? const Center(
                            child: Text('ブロックしている人はいません。'),
                          )
                        : ListView.builder(
                            itemCount: blockedMembers.length,
                            itemBuilder: (context, index) {
                              final m = blockedMembers[index];
                              return Card(
                                child: ListTile(
                                  title: Text(m['name']),
                                  trailing: TextButton(
                                    onPressed: () {
                                      _unblockUser(m['id']);
                                    },
                                    child: const Text(
                                      '解除',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  // --- ブロックを追加するボタン ---
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showAddBlockDialog,
                    child: const Text('ブロックする人を追加'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
 