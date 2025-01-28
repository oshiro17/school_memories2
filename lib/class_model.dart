class ClassModel {
  final String id;
  final String classNumber;
  final String name;
  final String password;
  final int userCount;

  ClassModel({
    required this.id,
    required this.classNumber,
    required this.name,
    required this.password,
    required this.userCount,
  });

  factory ClassModel.fromMap(Map<String, dynamic> map) {
    return ClassModel(
      id: map['id'] ?? '',
      classNumber: map['classNumber'] ?? '',
      name: map['name'] ?? '',
      password: map['password'] ?? '',
      userCount: map['userCount'] is int ? map['userCount'] as int : 0,
    );
  }
}
