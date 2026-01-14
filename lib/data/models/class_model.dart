class ClassModel {
  final int id;
  final String name;
  final int schoolId;
  final int teacherId;
  final String schoolName;
  final String teacherName;
  final int count;

  ClassModel({
    required this.id,
    required this.name,
    required this.schoolId,
    required this.teacherId,
    required this.schoolName,
    required this.teacherName,
    required this.count,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] as int,
      name: json['name'] as String,
      schoolId: json['schoolId'] as int,
      teacherId: json['teacherId'] as int,
      schoolName: json['schoolName'] as String,
      teacherName: json['teacherName'] as String,
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'schoolId': schoolId,
      'teacherId': teacherId,
      'schoolName': schoolName,
      'teacherName': teacherName,
      'count': count,
    };
  }
}
