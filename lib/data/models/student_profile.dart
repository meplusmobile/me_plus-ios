class StudentProfile {
  final int id;
  final String firstName;
  final String lastName;
  final String name;
  final String? email;
  final String? phone;
  final String? profileImageUrl;
  final int? schoolId;
  final int? classId;
  final String? schoolName;
  final String? birthDate;
  final String role;
  final String? levelName;
  final int? levelIndex;
  final String? levelImageUrl;
  final int points;
  final int credits;
  final int? levelMaxPoints;

  StudentProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.name,
    this.email,
    this.phone,
    this.profileImageUrl,
    this.schoolId,
    this.classId,
    this.schoolName,
    this.birthDate,
    required this.role,
    this.levelName,
    this.levelIndex,
    this.levelImageUrl,
    required this.points,
    required this.credits,
    this.levelMaxPoints,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    final firstName = json['firstName'] ?? '';
    final lastName = json['lastName'] ?? '';
    final fullName = '$firstName $lastName'.trim();

    return StudentProfile(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      firstName: firstName,
      lastName: lastName,
      name: fullName.isNotEmpty ? fullName : '',
      email: json['email'],
      phone: json['phoneNumber'],
      profileImageUrl: json['profileImageUrl'],
      schoolId: json['schoolId'] is int
          ? json['schoolId']
          : int.tryParse(json['schoolId']?.toString() ?? ''),
      classId: json['classId'] is int
          ? json['classId']
          : int.tryParse(json['classId']?.toString() ?? ''),
      schoolName: json['schoolName'],
      birthDate: json['birthDate'],
      role: json['role'] ?? 'Student',
      levelName: json['levelName'],
      levelIndex: json['levelIndex'],
      levelImageUrl: json['levelImageUrl'],
      points: json['points'] ?? 0,
      credits: json['credits'] ?? 0,
      levelMaxPoints: json['levelMaxPoints'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'name': name,
      'email': email,
      'phoneNumber': phone,
      'profileImageUrl': profileImageUrl,
      'schoolId': schoolId,
      'classId': classId,
      'schoolName': schoolName,
      'birthDate': birthDate,
      'role': role,
      'levelName': levelName,
      'levelIndex': levelIndex,
      'levelImageUrl': levelImageUrl,
      'points': points,
      'credits': credits,
      'levelMaxPoints': levelMaxPoints,
    };
  }
}
