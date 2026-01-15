import 'package:flutter/foundation.dart';
import 'package:me_plus/data/models/student_profile.dart';
import 'package:me_plus/data/repositories/student_repository.dart';
import 'package:me_plus/data/services/profile_storage_service.dart';

class ProfileProvider with ChangeNotifier {
  final StudentRepository _repository = StudentRepository();
  final ProfileStorageService _storage = ProfileStorageService();

  StudentProfile? _profile;
  bool _isLoading = false;
  String? _error;

  StudentProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _profile != null;

  int? get studentId => _profile?.id;
  int? get schoolId => _profile?.schoolId;
  int? get classId => _profile?.classId;
  int get points => _profile?.points ?? 0;
  int get credits => _profile?.credits ?? 0;
  String get studentName => _profile?.name ?? 'Student';

  ProfileProvider() {
    _loadProfileFromStorage();
  }

  Future<void> _loadProfileFromStorage() async {
    try {
      final savedProfile = await _storage.getProfile();
      if (savedProfile != null) {
        _profile = savedProfile;
        notifyListeners();
      }
    } catch (e) {
      // Error loading profile from storage
    }
  }

  // Fetch profile from API and save to storage
  Future<void> loadProfile({bool forceRefresh = false}) async {
    if (_isLoading) return;

    if (!forceRefresh && _profile != null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Fetch profile from /student/profile (includes points)
      final profile = await _repository.getProfile();

      _profile = profile;

      // Save to local storage
      await _storage.saveProfile(_profile!);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update points from API
  Future<void> updatePoints() async {
    try {
      final updatedProfile = await _repository.getProfile();

      if (_profile != null) {
        _profile = updatedProfile;

        // Save updated profile to storage
        await _storage.saveProfile(_profile!);
        notifyListeners();
      }
    } catch (e) {
      // Error updating points
    }
  }

  // Update profile information
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Update profile via API
      final updatedProfile = await _repository.updateProfile(data);

      _profile = updatedProfile;

      // Save updated profile to storage
      await _storage.saveProfile(_profile!);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Subtract credits locally (for purchases)
  void subtractCredits(int amount) {
    if (_profile != null && _profile!.credits >= amount) {
      _profile = StudentProfile(
        id: _profile!.id,
        firstName: _profile!.firstName,
        lastName: _profile!.lastName,
        name: _profile!.name,
        email: _profile!.email,
        phone: _profile!.phone,
        profileImageUrl: _profile!.profileImageUrl,
        schoolId: _profile!.schoolId,
        classId: _profile!.classId,
        schoolName: _profile!.schoolName,
        birthDate: _profile!.birthDate,
        role: _profile!.role,
        levelName: _profile!.levelName,
        levelIndex: _profile!.levelIndex,
        levelImageUrl: _profile!.levelImageUrl,
        points: _profile!.points,
        credits: _profile!.credits - amount,
        levelMaxPoints: _profile!.levelMaxPoints,
      );
      _storage.saveProfile(_profile!);
      notifyListeners();
    }
  }

  // Clear profile (on logout)
  Future<void> clearProfile() async {
    _profile = null;
    _error = null;
    await _storage.clearProfile();
    notifyListeners();
  }
}
