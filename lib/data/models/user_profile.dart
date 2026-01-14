class UserProfile {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? birthdate;
  final String role;
  final int? schoolId;
  final String? schoolName;
  final String? profileImageUrl;
  final String? address;

  UserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.birthdate,
    required this.role,
    this.schoolId,
    this.schoolName,
    this.profileImageUrl,
    this.address,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    String firstName = json['firstName'] as String;
    String? schoolName = json['schoolName'] as String?;
    final String role = json['role'] as String;

    // Decode Market Name from First Name if separator exists AND role is Market Owner
    if ((role == 'Market' || role == 'Market Owner') &&
        firstName.contains('||')) {
      final parts = firstName.split('||');
      if (parts.length > 1) {
        firstName = parts[0];
        schoolName = parts[1];
      }
    }

    return UserProfile(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String,
      firstName: firstName,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      birthdate: json['birthDate'] as String? ?? json['birthdate'] as String?,
      role: json['role'] as String,
      schoolId: json['schoolId'] as int?,
      schoolName: schoolName,
      profileImageUrl: json['profileImageUrl'] as String?,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'birthdate': birthdate,
      'role': role,
      'schoolId': schoolId,
      'schoolName': schoolName,
      'profileImageUrl': profileImageUrl,
      'address': address,
    };
  }
}
