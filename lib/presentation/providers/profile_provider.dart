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
  bool _isInitialized = false;

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

  // ✅ Constructor بدون استدعاءات plugin
  ProfileProvider();

  // ✅ Explicit initialization بعد first frame
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final savedProfile = await _storage.getProfile();
      if (savedProfile != null) {
        _profile = savedProfile;
        _isInitialized = true;
        notifyListeners();
      }
    } catch (e) {
      // Error loading profile from storage - safe to continue
      _isInitialized = true;
    }
  }

  // Fetch profile from API and save to storage
  Future<void> loadProfile({bool forceRefresh = false, int retryCount = 0}) async {
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
      debugPrint('❌ Error loading profile: $e');
      
      // Retry logic for network errors (max 2 retries)
      if (retryCount < 2 && _shouldRetry(e.toString())) {
        debugPrint('🔄 Retrying profile load (attempt ${retryCount + 1})...');
        await Future.delayed(Duration(seconds: 1 + retryCount));
        return loadProfile(forceRefresh: forceRefresh, retryCount: retryCount + 1);
      }
      
      _error = _getUserFriendlyError(e.toString());
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Check if error should trigger a retry
  bool _shouldRetry(String error) {
    final lowerError = error.toLowerCase();
    return lowerError.contains('timeout') ||
           lowerError.contains('connection') ||
           lowerError.contains('socket') ||
           lowerError.contains('network');
  }
  
  /// Convert technical errors to user-friendly messages
  String _getUserFriendlyError(String error) {
    final lowerError = error.toLowerCase();
    
    if (lowerError.contains('timeout')) {
      return 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.';
    }
    if (lowerError.contains('socket') || lowerError.contains('connection')) {
      return 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال.';
    }
    if (lowerError.contains('401') || lowerError.contains('unauthorized')) {
      return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.';
    }
    if (lowerError.contains('404')) {
      return 'لم يتم العثور على البيانات المطلوبة.';
    }
    if (lowerError.contains('500') || lowerError.contains('server')) {
      return 'خطأ في الخادم. يرجى المحاولة لاحقاً.';
    }
    
    // Remove "Exception: " prefix if present
    if (error.startsWith('Exception: ')) {
      return error.substring(11);
    }
    
    return error;
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
