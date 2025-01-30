class SelectPeopleModel {
  final String id;
  final String name;
  final int avatarIndex; // アバター番号も持っている例

  SelectPeopleModel({
    required this.id,
    required this.name,
    required this.avatarIndex,
  });

  // doc.data() を as Map<String,dynamic> でキャストして受け取る想定
  factory SelectPeopleModel.fromMap(Map<String, dynamic> map) {
    return SelectPeopleModel(
      id: map['id'] ?? '',
      name: map['name'] ?? 'NoName',
      avatarIndex: map['avatarIndex'] ?? 0,
    );
  }
}
