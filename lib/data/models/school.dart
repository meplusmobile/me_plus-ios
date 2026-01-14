class School {
  final int id;
  final String name;
  final String phoneNumber;
  final String registrationDate;
  final String city;
  final String address;
  final int principalId;
  final String principalEmail;
  final String principalName;

  School({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.registrationDate,
    required this.city,
    required this.address,
    required this.principalId,
    required this.principalEmail,
    required this.principalName,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'] as int,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      registrationDate: json['registrationDate'] as String,
      city: json['city'] as String,
      address: json['address'] as String,
      principalId: json['principalId'] as int,
      principalEmail: json['principalEmail'] as String,
      principalName: json['principalName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'registrationDate': registrationDate,
      'city': city,
      'address': address,
      'principalId': principalId,
      'principalEmail': principalEmail,
      'principalName': principalName,
    };
  }
}
