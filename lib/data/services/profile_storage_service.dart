import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:me_plus/data/models/student_profile.dart';

class ProfileStorageService {
  static const String _profileKey = 'student_profile';

  // Save profile
  Future<void> saveProfile(StudentProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = json.encode(profile.toJson());
    await prefs.setString(_profileKey, profileJson);
  }

  // Get profile
  Future<StudentProfile?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_profileKey);

    if (profileJson == null) return null;

    try {
      final profileMap = json.decode(profileJson) as Map<String, dynamic>;
      return StudentProfile.fromJson(profileMap);
    } catch (e) {
      return null;
    }
  }

  // Clear profile
  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }

  // Check if profile exists
  Future<bool> hasProfile() async {
    final profile = await getProfile();
    return profile != null;
  }

  // Get specific IDs
  Future<int?> getStudentId() async {
    final profile = await getProfile();
    return profile?.id;
  }

  Future<int?> getSchoolId() async {
    final profile = await getProfile();
    return profile?.schoolId;
  }

  Future<int?> getClassId() async {
    final profile = await getProfile();
    return profile?.classId;
  }

  // Update points only
  Future<void> updatePoints(int newPoints) async {
    final profile = await getProfile();
    if (profile != null) {
      final updatedProfile = StudentProfile(
        id: profile.id,
        firstName: profile.firstName,
        lastName: profile.lastName,
        name: profile.name,
        email: profile.email,
        phone: profile.phone,
        profileImageUrl: profile.profileImageUrl,
        schoolId: profile.schoolId,
        classId: profile.classId,
        schoolName: profile.schoolName,
        birthDate: profile.birthDate,
        role: profile.role,
        levelName: profile.levelName,
        levelIndex: profile.levelIndex,
        levelImageUrl: profile.levelImageUrl,
        points: newPoints,
        credits: profile.credits,
        levelMaxPoints: profile.levelMaxPoints,
      );
      await saveProfile(updatedProfile);
    }
  }
}
