import 'dart:developer' as developer;
import 'package:me_plus/data/repositories/student_repository.dart';
import 'package:me_plus/data/models/activity_model.dart';

class PrefetchService {
  static final PrefetchService _instance = PrefetchService._internal();
  factory PrefetchService() => _instance;
  PrefetchService._internal();

  final StudentRepository _repository = StudentRepository();

  bool _isPrefetching = false;
  bool _isPrefetchComplete = false;

  // Cache for prefetched data
  List<NotificationModel>? _cachedNotifications;
  List<Activity>? _cachedActivities;

  bool get isPrefetchComplete => _isPrefetchComplete;
  List<NotificationModel>? get cachedNotifications => _cachedNotifications;
  List<Activity>? get cachedActivities => _cachedActivities;

  /// Start prefetching all backend text and translations
  Future<void> startPrefetch() async {
    if (_isPrefetching || _isPrefetchComplete) return;

    _isPrefetching = true;
    developer.log(
      '🚀 Starting background prefetch...',
      name: 'PrefetchService',
    );

    try {
      // Run all prefetch operations in parallel
      await Future.wait([_prefetchNotifications(), _prefetchActivities()]);

      _isPrefetchComplete = true;
      developer.log(
        '✅ Prefetch completed successfully',
        name: 'PrefetchService',
      );
    } catch (e) {
      developer.log('❌ Prefetch error: $e', name: 'PrefetchService');
    } finally {
      _isPrefetching = false;
    }
  }

  /// Prefetch and translate notifications
  Future<void> _prefetchNotifications() async {
    try {
      developer.log('📥 Prefetching notifications...', name: 'PrefetchService');
      _cachedNotifications = await _repository.getNotifications();
      developer.log(
        '✓ Cached ${_cachedNotifications?.length ?? 0} notifications',
        name: 'PrefetchService',
      );
    } catch (e) {
      developer.log(
        '⚠️ Failed to prefetch notifications: $e',
        name: 'PrefetchService',
      );
    }
  }

  /// Prefetch and translate activities/behaviors
  Future<void> _prefetchActivities() async {
    try {
      developer.log('📥 Prefetching activities...', name: 'PrefetchService');
      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month}-${today.day}';
      _cachedActivities = await _repository.getBehaviorsByDay(date: dateStr);
      developer.log(
        '✓ Cached ${_cachedActivities?.length ?? 0} activities',
        name: 'PrefetchService',
      );
    } catch (e) {
      developer.log(
        '⚠️ Failed to prefetch activities: $e',
        name: 'PrefetchService',
      );
    }
  }

  /// Clear all cached data
  void clearCache() {
    _cachedNotifications = null;
    _cachedActivities = null;
    _isPrefetchComplete = false;
    developer.log('🗑️ Cache cleared', name: 'PrefetchService');
  }

  /// Refresh cached data
  Future<void> refresh() async {
    clearCache();
    await startPrefetch();
  }
}
