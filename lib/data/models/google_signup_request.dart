class GoogleSignupRequest {
  final String accessToken;
  final String birthDate;
  final String role;
  final String phoneNumber;
  final String password;
  final String? firstName;
  final String? marketName;
  final String? address;

  GoogleSignupRequest({
    required this.accessToken,
    required this.birthDate,
    required this.role,
    required this.phoneNumber,
    required this.password,
    this.marketName,
    this.address,
    this.firstName,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'accessToken': accessToken,
      'BirthDate': birthDate,
      'role': role,
      'phoneNumber': phoneNumber,
      'password': password,
    };

    // Add market-specific fields if present
    if (marketName != null) {
      json['marketName'] = marketName!;
    }
    if (address != null) {
      json['address'] = address!;
    }
    if (firstName != null) {
      json['firstName'] = firstName!;
    }

    return json;
  }
}
