import 'package:flutter/material.dart';

class SignupData extends ChangeNotifier {
  String? firstName;
  String? lastName;
  String? email;
  String? phoneNumber;
  String? password;
  String? birthdate;
  String? role;

  // Student specific
  String? schoolId;
  String? grade;

  // Parent specific
  List<String>? childrenEmails;

  // Market owner specific
  String? marketName;
  String? marketAddress;

  void setBasicInfo({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    required String birthdate,
  }) {
    this.firstName = firstName;
    this.lastName = lastName;
    this.email = email;
    this.phoneNumber = phoneNumber;
    this.password = password;
    this.birthdate = birthdate;
    notifyListeners();
  }

  void setRole(String role) {
    this.role = role;
    notifyListeners();
  }

  void setStudentInfo({required String schoolId, required String grade}) {
    this.schoolId = schoolId;
    this.grade = grade;
    notifyListeners();
  }

  void setParentInfo({required List<String> childrenEmails}) {
    this.childrenEmails = childrenEmails;
    notifyListeners();
  }

  void setMarketOwnerInfo({
    required String marketName,
    required String marketAddress,
  }) {
    this.marketName = marketName;
    this.marketAddress = marketAddress;
    notifyListeners();
  }

  void clear() {
    firstName = null;
    lastName = null;
    email = null;
    phoneNumber = null;
    password = null;
    birthdate = null;
    role = null;
    schoolId = null;
    grade = null;
    childrenEmails = null;
    marketName = null;
    marketAddress = null;
    notifyListeners();
  }

  bool get hasBasicInfo =>
      firstName != null &&
      lastName != null &&
      email != null &&
      phoneNumber != null &&
      password != null &&
      birthdate != null;

  bool get isComplete {
    if (!hasBasicInfo || role == null) return false;

    switch (role) {
      case 'Student':
        return schoolId != null && grade != null;
      case 'Parent':
        return childrenEmails != null && childrenEmails!.isNotEmpty;
      case 'MarketOwner':
        return marketName != null && marketAddress != null;
      default:
        return false;
    }
  }
}
