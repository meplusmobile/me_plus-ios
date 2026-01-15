import 'package:me_plus/data/services/api_service.dart';
import 'package:me_plus/data/models/user_profile.dart';
import 'package:me_plus/data/models/activity_model.dart';
import 'package:me_plus/data/models/store_model.dart';
import 'package:me_plus/data/models/child_model.dart';
import 'package:me_plus/data/models/behavior_model.dart';
import 'package:me_plus/data/models/child_reward_model.dart';
import 'package:me_plus/core/services/translation_service.dart';
import 'package:dio/dio.dart';

class ParentRepository {
  final ApiService _apiService = ApiService();
  final TranslationService _translationService = TranslationService();

  // Get all children for the parent
  Future<List<Child>> getChildren() async {
    try {
      final response = await _apiService.get('/parent/children');

      if (response.data is List) {
        return (response.data as List)
            .map((child) => Child.fromJson(child))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Error fetching children: $e');
    }
  }

  // Get waiting children (pending approval)
  Future<List<Child>> getWaitingChildren() async {
    try {
      final response = await _apiService.get('/parent/waiting-children');

      if (response.data is List) {
        return (response.data as List)
            .map((child) => Child.fromJson(child))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Error fetching waiting children: $e');
    }
  }

  // Get child activity for a specific month (calendar markers)
  Future<List<BehaviorDate>> getChildActivity({
    required int schoolId,
    required int classId,
    required String childId,
    required String date, // Format: "YYYY-MM"
  }) async {
    try {
      final response = await _apiService.get(
        '/api/schools/$schoolId/classes/$classId/childs/$childId/activity?date=$date',
      );

      if (response.data != null && response.data['dates'] is List) {
        return (response.data['dates'] as List)
            .map((dateItem) => BehaviorDate.fromJson(dateItem))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Error fetching child activity: $e');
    }
  }

  // Get last 4 days activities for a child
  Future<List<BehaviorDate>> getLastWeekActivities({
    required int schoolId,
    required int classId,
    required String childId,
  }) async {
    try {
      final now = DateTime.now();
      final fourDaysAgo = now.subtract(const Duration(days: 4));

      // Check if we need to fetch from previous month as well
      final needsPreviousMonth = fourDaysAgo.month != now.month;

      final List<BehaviorDate> allDates = [];

      // Fetch current month
      final currentMonthStr = '${now.year}-${now.month}';
      final currentResponse = await _apiService.get(
        '/api/schools/$schoolId/classes/$classId/childs/$childId/activity?date=$currentMonthStr',
      );

      if (currentResponse.data != null &&
          currentResponse.data['dates'] is List) {
        allDates.addAll(
          (currentResponse.data['dates'] as List)
              .map((dateItem) => BehaviorDate.fromJson(dateItem))
              .toList(),
        );
      }

      // Fetch previous month if needed
      if (needsPreviousMonth) {
        final previousMonthStr = '${fourDaysAgo.year}-${fourDaysAgo.month}';
        final previousResponse = await _apiService.get(
          '/api/schools/$schoolId/classes/$classId/childs/$childId/activity?date=$previousMonthStr',
        );

        if (previousResponse.data != null &&
            previousResponse.data['dates'] is List) {
          allDates.addAll(
            (previousResponse.data['dates'] as List)
                .map((dateItem) => BehaviorDate.fromJson(dateItem))
                .toList(),
          );
        }
      }

      // Filter to get only last 4 days (excluding today, days: -1, -2, -3, -4)
      final lastFourDays = allDates.where((behaviorDate) {
        final daysDifference = now.difference(behaviorDate.date).inDays;
        return daysDifference >= 1 && daysDifference <= 4;
      }).toList();

      // Sort by date ascending (oldest first for display left-to-right)
      lastFourDays.sort((a, b) => a.date.compareTo(b.date));

      return lastFourDays;
    } catch (e) {
      return [];
    }
  }

  // Get child behaviors for a specific day
  Future<List<Activity>> getChildBehaviorsByDay({
    required int schoolId,
    required int classId,
    required String childId,
    required String date, // Format: "YYYY-M-D"
  }) async {
    try {
      final response = await _apiService.get(
        '/api/schools/$schoolId/classes/$classId/childs/$childId/behaviors',
        queryParameters: {'date': date},
      );

      final data = response.data;
      List<Activity> activities = [];

      if (data is Map && data.containsKey('items')) {
        activities = (data['items'] as List)
            .map((item) => Activity.fromJson(item))
            .toList();
      } else if (data is Map && data.containsKey('data')) {
        activities = (data['data'] as List)
            .map((item) => Activity.fromJson(item))
            .toList();
      } else if (data is List) {
        activities = data.map((item) => Activity.fromJson(item)).toList();
      }

      // Auto-translate activities
      final translatedActivities = <Activity>[];
      for (var activity in activities) {
        translatedActivities.add(await _autoTranslateActivity(activity));
      }

      return translatedActivities;
    } catch (e) {
      throw Exception('Error fetching child behaviors by day: $e');
    }
  }

  Future<Activity> _autoTranslateActivity(Activity activity) async {
    String? titleAr = activity.titleAr;
    String? titleEn = activity.titleEn;
    String? descriptionAr = activity.descriptionAr;
    String? descriptionEn = activity.descriptionEn;

    if (titleAr == null && titleEn == null && activity.title.isNotEmpty) {
      final detectedLang = _translationService.detectLanguage(activity.title);
      if (detectedLang == 'ar') {
        titleAr = activity.title;
        titleEn = await _translationService.translateToEnglish(activity.title);
      } else {
        titleEn = activity.title;
        titleAr = await _translationService.translateToArabic(activity.title);
      }
    } else if (titleAr == null && titleEn != null) {
      titleAr = await _translationService.translateToArabic(titleEn);
    } else if (titleEn == null && titleAr != null) {
      titleEn = await _translationService.translateToEnglish(titleAr);
    }

    if (descriptionAr == null &&
        descriptionEn == null &&
        activity.description.isNotEmpty) {
      final detectedLang = _translationService.detectLanguage(
        activity.description,
      );
      if (detectedLang == 'ar') {
        descriptionAr = activity.description;
        descriptionEn = await _translationService.translateToEnglish(
          activity.description,
        );
      } else {
        descriptionEn = activity.description;
        descriptionAr = await _translationService.translateToArabic(
          activity.description,
        );
      }
    } else if (descriptionAr == null && descriptionEn != null) {
      descriptionAr = await _translationService.translateToArabic(
        descriptionEn,
      );
    } else if (descriptionEn == null && descriptionAr != null) {
      descriptionEn = await _translationService.translateToEnglish(
        descriptionAr,
      );
    }

    return activity.copyWith(
      titleAr: titleAr ?? activity.title,
      titleEn: titleEn ?? activity.title,
      descriptionAr: descriptionAr ?? activity.description,
      descriptionEn: descriptionEn ?? activity.description,
    );
  }

  // Get child behavior for this month
  Future<List<BehaviorRecord>> getChildBehaviorThisMonth({
    required int schoolId,
    required int classId,
    required String childId,
  }) async {
    try {
      final response = await _apiService.get(
        '/api/schools/$schoolId/classes/$classId/childs/$childId/behavior/this-month',
      );

      if (response.data is List) {
        return (response.data as List)
            .map((behavior) => BehaviorRecord.fromJson(behavior))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Error fetching child behavior: $e');
    }
  }

  // Get child behavior for last month
  Future<List<BehaviorRecord>> getChildBehaviorLastMonth({
    required int schoolId,
    required int classId,
    required String childId,
  }) async {
    try {
      final response = await _apiService.get(
        '/api/schools/$schoolId/classes/$classId/childs/$childId/behavior/last-month',
      );

      if (response.data is List) {
        return (response.data as List)
            .map((behavior) => BehaviorRecord.fromJson(behavior))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Error fetching child behavior: $e');
    }
  }

  Future<UserProfile> getParentProfile() async {
    try {
      // Assuming /parent/profile exists, or we might use /api/me
      final response = await _apiService.get('/parent/profile');
      return UserProfile.fromJson(response.data);
    } catch (e) {
      // Fallback to /api/me if /parent/profile fails?
      // Or maybe the user meant "exactly same" backend means same endpoints?
      // But /market/profile implies role specific.
      // I will try /parent/profile first.
      throw Exception('Error fetching parent profile: $e');
    }
  }

  Future<UserProfile> updateParentProfile(Map<String, dynamic> data) async {
    try {
      final formData = FormData.fromMap(data);

      await _apiService.put('/api/me', data: formData, isFormData: true);

      return await getParentProfile();
    } catch (e) {
      throw Exception('Error updating parent profile: $e');
    }
  }

  // Notification methods (Same as MarketRepository)
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _apiService.get('/api/notifications');

    if (response.data is List) {
      final notifications = (response.data as List)
          .map((notification) => NotificationModel.fromJson(notification))
          .toList();

      // Auto-translate notifications but preserve names
      final translatedNotifications = <NotificationModel>[];
      for (var notification in notifications) {
        translatedNotifications.add(
          await _autoTranslateNotification(notification),
        );
      }

      return translatedNotifications;
    }

    return [];
  }

  Future<NotificationModel> _autoTranslateNotification(
    NotificationModel notification,
  ) async {
    String? titleAr = notification.titleAr;
    String? titleEn = notification.titleEn;
    String? messageAr = notification.messageAr;
    String? messageEn = notification.messageEn;

    if (titleAr == null && titleEn == null && notification.title.isNotEmpty) {
      final detectedLang = _translationService.detectLanguage(
        notification.title,
      );
      if (detectedLang == 'ar') {
        titleAr = notification.title;
        titleEn = await _translationService.translateToEnglish(
          notification.title,
        );
      } else {
        titleEn = notification.title;
        titleAr = await _translationService.translateToArabic(
          notification.title,
        );
      }
    } else if (titleAr == null && titleEn != null) {
      titleAr = await _translationService.translateToArabic(titleEn);
    } else if (titleEn == null && titleAr != null) {
      titleEn = await _translationService.translateToEnglish(titleAr);
    }

    if (messageAr == null &&
        messageEn == null &&
        notification.message.isNotEmpty) {
      final detectedLang = _translationService.detectLanguage(
        notification.message,
      );
      if (detectedLang == 'ar') {
        messageAr = notification.message;
        messageEn = await _smartTranslateMessage(
          notification.message,
          'ar',
          'en',
        );
      } else {
        messageEn = notification.message;
        messageAr = await _smartTranslateMessage(
          notification.message,
          'en',
          'ar',
        );
      }
    } else if (messageAr == null && messageEn != null) {
      messageAr = await _smartTranslateMessage(messageEn, 'en', 'ar');
    } else if (messageEn == null && messageAr != null) {
      messageEn = await _smartTranslateMessage(messageAr, 'ar', 'en');
    }

    return NotificationModel(
      id: notification.id,
      title: notification.title,
      message: notification.message,
      titleAr: titleAr ?? notification.title,
      titleEn: titleEn ?? notification.title,
      messageAr: messageAr ?? notification.message,
      messageEn: messageEn ?? notification.message,
      createdAt: notification.createdAt,
      isRead: notification.isRead,
      type: notification.type,
      imageUrl: notification.imageUrl,
    );
  }

  Future<String> _smartTranslateMessage(
    String message,
    String fromLang,
    String toLang,
  ) async {
    // Pattern 1: "ItemName has been ordered from StudentName"
    final orderPattern = RegExp(r'^(.+?)\s+has been ordered from\s+(.+)$');
    final orderMatch = orderPattern.firstMatch(message);

    if (orderMatch != null) {
      final itemName = orderMatch.group(1)?.trim() ?? '';
      final studentName = orderMatch.group(2)?.trim() ?? '';

      if (toLang == 'ar') {
        return 'لقد تم طلب $itemName من قبل $studentName';
      }
    }

    // Pattern 2: "You requested a ItemName, Did you receive it?"
    final requestPattern = RegExp(
      r'You requested a\s+(.+?),\s*Did you receive it\??',
      caseSensitive: false,
    );
    final requestMatch = requestPattern.firstMatch(message);

    if (requestMatch != null) {
      final itemName = requestMatch.group(1)?.trim() ?? '';

      if (toLang == 'ar') {
        return 'لقد طلبت $itemName، هل استلمتها؟';
      }
    }

    // Pattern 3: "A new behavior has been assigned to your child StudentName by teacher TeacherName"
    final behaviorPattern = RegExp(
      r'A new behavior has been assigned to your child\s+(.+?)\s+by teacher\s+(.+)$',
      caseSensitive: false,
    );
    final behaviorMatch = behaviorPattern.firstMatch(message);

    if (behaviorMatch != null) {
      final studentName = behaviorMatch.group(1)?.trim() ?? '';
      final teacherName = behaviorMatch.group(2)?.trim() ?? '';

      if (toLang == 'ar') {
        return 'تم تعيين سلوك جديد لطفلك $studentName من قبل المعلم $teacherName';
      }
    }

    // Pattern 4: Arabic "لقد تم طلب ItemName من قبل StudentName"
    final arabicOrderPattern = RegExp(r'لقد تم طلب\s+(.+?)\s+من قبل\s+(.+)$');
    final arabicOrderMatch = arabicOrderPattern.firstMatch(message);

    if (arabicOrderMatch != null && toLang == 'en') {
      final itemName = arabicOrderMatch.group(1)?.trim() ?? '';
      final studentName = arabicOrderMatch.group(2)?.trim() ?? '';
      return '$itemName has been ordered from $studentName';
    }

    // Pattern 5: Arabic "لقد طلبت ItemName، هل استلمتها؟"
    final arabicRequestPattern = RegExp(r'لقد طلبت\s+(.+?)،\s*هل استلمتها؟');
    final arabicRequestMatch = arabicRequestPattern.firstMatch(message);

    if (arabicRequestMatch != null && toLang == 'en') {
      final itemName = arabicRequestMatch.group(1)?.trim() ?? '';
      return 'You requested a $itemName, Did you receive it?';
    }

    // Pattern 6: Arabic behavior notification
    final arabicBehaviorPattern = RegExp(
      r'تم تعيين سلوك جديد لطفلك\s+(.+?)\s+من قبل المعلم\s+(.+)$',
    );
    final arabicBehaviorMatch = arabicBehaviorPattern.firstMatch(message);

    if (arabicBehaviorMatch != null && toLang == 'en') {
      final studentName = arabicBehaviorMatch.group(1)?.trim() ?? '';
      final teacherName = arabicBehaviorMatch.group(2)?.trim() ?? '';
      return 'A new behavior has been assigned to your child $studentName by teacher $teacherName';
    }

    // If no pattern matches, use regular translation
    if (toLang == 'ar') {
      return await _translationService.translateToArabic(message);
    } else {
      return await _translationService.translateToEnglish(message);
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    await _apiService.post('/api/notifications/mark-as-read/$notificationId');
  }

  Future<void> deleteNotification(int notificationId) async {
    await _apiService.delete('/api/notifications/$notificationId');
  }

  Future<List<Purchase>> getChildPurchases({required int studentId}) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Purchase(
        id: 1,
        studentId: studentId,
        rewardId: 1,
        rewardName: 'Pen',
        pointsSpent: 200,
        status: 'Delivered',
        purchaseDate: DateTime.now().subtract(const Duration(days: 2)),
        image: '',
        market: 'School Store',
        marketAddress: 'Room 101',
      ),
      Purchase(
        id: 2,
        studentId: studentId,
        rewardId: 2,
        rewardName: 'Notebook',
        pointsSpent: 300,
        status: 'Pending',
        purchaseDate: DateTime.now().subtract(const Duration(days: 5)),
        image: '',
        market: 'School Store',
        marketAddress: 'Room 101',
      ),
      Purchase(
        id: 3,
        studentId: studentId,
        rewardId: 3,
        rewardName: 'Eraser',
        pointsSpent: 50,
        status: 'Rejected',
        purchaseDate: DateTime.now().subtract(const Duration(days: 10)),
        image: '',
        market: 'School Store',
        marketAddress: 'Room 101',
      ),
    ];
  }

  // ==================== Child Report APIs ====================

  // Get total points exchanged by child
  Future<double> getChildTotalPointsExchanged({
    required int schoolId,
    required int classId,
    required String childId,
    required String date, // Format: "YYYY-MM"
  }) async {
    try {
      final response = await _apiService.get(
        '/api/schools/$schoolId/classes/$classId/childs/$childId/behavior/total-points-exchanged',
        queryParameters: {'date': date},
      );

      final value = response.data['totalPointsExchanged'];
      return value != null
          ? (value is double ? value : (value as num).toDouble())
          : 0.0;
    } catch (e) {
      throw Exception('Error fetching total points exchanged: $e');
    }
  }

  // Get total credits exchanged by child
  Future<double> getChildTotalCreditsExchanged({
    required int schoolId,
    required int classId,
    required String childId,
    required String date, // Format: "YYYY-MM"
  }) async {
    try {
      final response = await _apiService.get(
        '/api/schools/$schoolId/classes/$classId/childs/$childId/behavior/total-credits-exchanged',
        queryParameters: {'date': date},
      );

      final value = response.data['totalCreditsExchanged'];
      return value != null
          ? (value is double ? value : (value as num).toDouble())
          : 0.0;
    } catch (e) {
      throw Exception('Error fetching total credits exchanged: $e');
    }
  }

  // Get total points given to child for specified month
  Future<int> getChildTotalPointsGiven({
    required int schoolId,
    required int classId,
    required String childId,
    required String date, // Format: "YYYY-MM"
  }) async {
    try {
      final response = await _apiService.get(
        '/api/schools/$schoolId/classes/$classId/childs/$childId/behavior/total-points-given',
        queryParameters: {'date': date},
      );

      final value = response.data['totalPointsGiven'];
      return value != null
          ? (value is int ? value : (value as num).toInt())
          : 0;
    } catch (e) {
      throw Exception('Error fetching total points given: $e');
    }
  }

  // Get total credits given to child for specified month
  Future<int> getChildTotalCreditsGiven({
    required int schoolId,
    required int classId,
    required String childId,
    required String date, // Format: "YYYY-MM"
  }) async {
    try {
      final response = await _apiService.get(
        '/api/schools/$schoolId/classes/$classId/childs/$childId/behavior/total-credits-given',
        queryParameters: {'date': date},
      );

      final value = response.data['totalCreditsGiven'];
      return value != null
          ? (value is int ? value : (value as num).toInt())
          : 0;
    } catch (e) {
      throw Exception('Error fetching total credits given: $e');
    }
  }

  // Get child behavior counts (positive and negative)
  // date parameter can be "YYYY-MM" for month or "YYYY-MM-DD" for day
  Future<Map<String, int>> getChildBehaviorCounts({
    required int schoolId,
    required int classId,
    required String childId,
    required String date, // Format: "YYYY-MM" for month or "YYYY-MM-DD" for day
  }) async {
    try {
      final response = await _apiService.get(
        '/api/schools/$schoolId/classes/$classId/childs/$childId/behavior/counts',
        queryParameters: {'date': date},
      );

      return {
        'positiveCount': response.data['positiveCount'] ?? 0,
        'negativeCount': response.data['negativeCount'] ?? 0,
      };
    } catch (e) {
      throw Exception('Error fetching behavior counts: $e');
    }
  }

  // Get child purchased rewards info with images
  // date parameter format: "YYYY-M" (e.g., "2025-7")
  Future<List<ChildReward>> getChildRewardInfo({
    required int schoolId,
    required int classId,
    required String childId,
    required String date, // Format: "YYYY-M"
  }) async {
    try {
      final response = await _apiService.get(
        '/api/schools/$schoolId/classes/$classId/childs/$childId/behavior/reward-info',
        queryParameters: {'date': date},
      );

      if (response.data != null && response.data['rewardImages'] is List) {
        return (response.data['rewardImages'] as List)
            .map((rewardItem) => ChildReward.fromJson(rewardItem))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Error fetching reward info: $e');
    }
  }
}
