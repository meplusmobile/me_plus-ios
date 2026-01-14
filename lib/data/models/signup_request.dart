class SignupRequest {
  final String firstName;
  final String lastName;
  final String birthdate;
  final String role;
  final String email;
  final String phoneNumber;
  final String password;
  final String? marketName;
  final String? address;
  final String? schoolId;
  final String? grade;
  final List<String>? childrenEmails;

  SignupRequest({
    required this.firstName,
    required this.lastName,
    required this.birthdate,
    required this.role,
    required this.email,
    required this.phoneNumber,
    required this.password,
    this.marketName,
    this.address,
    this.schoolId,
    this.grade,
    this.childrenEmails,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'birthdate': birthdate,
      'role': role,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
    };

    if (marketName != null) map['marketName'] = marketName!;
    if (address != null) map['address'] = address!;
    if (schoolId != null) map['schoolId'] = schoolId!;
    if (grade != null) map['grade'] = grade!;
    if (childrenEmails != null) map['childrenEmails'] = childrenEmails!;

    return map;
  }
}
