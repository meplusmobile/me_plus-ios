class AuthResponse {
  final String token;
  final String refreshToken;
  final int id;
  final String email;
  final int? schoolId;
  final String role;
  final bool isFirstTimeUser;

  AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.id,
    required this.email,
    this.schoolId,
    required this.role,
    required this.isFirstTimeUser,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      email: json['email'] as String,
      schoolId: json['schoolId'] == null
          ? null
          : (json['schoolId'] is int
                ? json['schoolId']
                : int.parse(json['schoolId'].toString())),
      role: json['role'] as String,
      isFirstTimeUser: json['isFirstTimeUser'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'id': id,
      'email': email,
      'schoolId': schoolId,
      'role': role,
      'isFirstTimeUser': isFirstTimeUser,
    };
  }
}
