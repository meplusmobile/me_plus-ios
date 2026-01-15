import 'package:flutter/foundation.dart';

class GoogleSignupProvider extends ChangeNotifier {
  String? accessToken;
  String? email;
  String? firstName;
  String? lastName;
  String? photoUrl;

  // Additional fields needed for signup
  String? birthDate;
  String? role;
  String? phoneNumber;
  String? password;

  // Student specific
  String? schoolId;
  String? classId;

  // Parent specific
  List<String>? childrenEmails;

  // Market owner specific
  String? marketName;
  String? marketAddress;

  /// Set Google user info from sign-in
  void setGoogleUserInfo({
    required String accessToken,
    String? email,
    String? firstName,
    String? lastName,
    String? photoUrl,
  }) {
    this.accessToken = accessToken;
    this.email = email;
    this.firstName = firstName;
    this.lastName = lastName;
    this.photoUrl = photoUrl;
    notifyListeners();
  }

  /// Set additional signup info
  void setAdditionalInfo({
    required String birthDate,
    required String role,
    required String phoneNumber,
    required String password,
  }) {
    this.birthDate = birthDate;
    this.role = role;
    this.phoneNumber = phoneNumber;
    this.password = password;
    notifyListeners();
  }

  void setStudentInfo({required String schoolId, required String classId}) {
    this.schoolId = schoolId;
    this.classId = classId;
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

  /// Check if we have access token
  bool get hasGoogleAuth => accessToken != null;

  /// Check if basic info is complete
  bool get hasBasicInfo =>
      birthDate != null &&
      role != null &&
      phoneNumber != null &&
      password != null;

  /// Check if all required data is complete
  fullName != null && fullName!.isNotEmpty;

  bool get isComplete {
    if (!hasGoogleAuth || !hasBasicInfo) return false;

    switch (role) {
      case 'Student':
        return schoolId != null && classId != null;
      case 'Parent':
        return childrenEmails != null && childrenEmails!.isNotEmpty;
      case 'Market':
        return marketName != null && marketAddress != null;
      default:
        return false;
    }
  }

  void clear() {
    accessToken = null;
    email = null;
    firstName = null;
    lastName = null;
    photoUrl = null;
    birthDate = null;
    role = null;
    phoneNumber = null;
    password = null;
    schoolId = null;
    classId = null;
    childrenEmails = null;
    marketName = null;
    marketAddress = null;
    notifyListeners();
  }
}
