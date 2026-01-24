class Child {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final DateTime? birthDate;
  final String levelName;
  final String levelImageUrl;
  final int levelIndex;
  final int points;
  final int credits;
  final String? imageUrl;
  final String backgroundColor;
  final int classId;
  final String className;
  final int schoolId;

  Child({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.birthDate,
    required this.levelName,
    required this.levelImageUrl,
    required this.levelIndex,
    required this.points,
    required this.credits,
    this.imageUrl,
    required this.backgroundColor,
    required this.classId,
    required this.className,
    required this.schoolId,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    // Parse birth date
    DateTime? parsedBirthDate;
    if (json['birthDate'] != null && json['birthDate'] != '0001-01-01') {
      try {
        parsedBirthDate = DateTime.parse(json['birthDate']);
      } catch (e) {
        parsedBirthDate = null;
      }
    }

    // Construct full image URL if needed
    String? fullImageUrl = json['imageUrl'];
    if (fullImageUrl != null &&
        fullImageUrl.isNotEmpty &&
        !fullImageUrl.startsWith('http')) {
      fullImageUrl =
          'https://meplus2.blob.core.windows.net/images/$fullImageUrl';
    }

    // Construct level image URL
    String levelImageUrl = json['levelImageUrl'] ?? '';
    if (levelImageUrl.isNotEmpty && !levelImageUrl.startsWith('http')) {
      levelImageUrl =
          'https://meplus2.blob.core.windows.net/images/$levelImageUrl';
    }

    return Child(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      birthDate: parsedBirthDate,
      levelName: json['levelName'] ?? '',
      levelImageUrl: levelImageUrl,
      levelIndex: json['levelIndex'] ?? 0,
      points: json['points'] ?? 0,
      credits: json['credits'] ?? 0,
      imageUrl: fullImageUrl,
      backgroundColor: json['backgroundColor'] ?? '#6B8BCA',
      classId: json['classId'] ?? 0,
      className: json['className'] ?? '',
      schoolId: json['schoolId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'birthDate': birthDate?.toIso8601String(),
      'levelName': levelName,
      'levelImageUrl': levelImageUrl,
      'levelIndex': levelIndex,
      'points': points,
      'credits': credits,
      'imageUrl': imageUrl,
      'backgroundColor': backgroundColor,
      'classId': classId,
      'className': className,
      'schoolId': schoolId,
    };
  }

  String get fullName => '$firstName $lastName';
}
