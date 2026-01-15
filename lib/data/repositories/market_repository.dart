import 'package:me_plus/data/services/api_service.dart';
import 'package:me_plus/data/models/user_profile.dart';
import 'package:me_plus/data/models/store_model.dart';
import 'package:me_plus/data/models/activity_model.dart';
import 'package:me_plus/data/models/order_model.dart';
import 'package:me_plus/core/services/translation_service.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class MarketRepository {
  final ApiService _apiService = ApiService();
  final TranslationService _translationService = TranslationService();

  Future<UserProfile> getMarketProfile() async {
    try {
      final response = await _apiService.get('/market/profile');
      return UserProfile.fromJson(response.data);
    } catch (e) {
      throw Exception('Error fetching market profile: $e');
    }
  }

  Future<UserProfile> updateMarketProfile(Map<String, dynamic> data) async {
    try {
      // Create FormData
      final formData = FormData.fromMap(data);

      await _apiService.put('/api/me', data: formData, isFormData: true);

      // Fetch full profile data again to ensure we have the latest state
      return await getMarketProfile();
    } catch (e) {
      throw Exception('Error updating market profile: $e');
    }
  }

  Future<List<StoreReward>> getMarketItems({
    String sortType = 'sortBy',
    String sortValue = 'oldest',
  }) async {
    final Map<String, dynamic> queryParams = {'pageSize': 35, 'pageNumber': 1};

    // Add the appropriate sort parameter
    if (sortType == 'sortBy') {
      queryParams['sortBy'] = sortValue; // oldest or newest
    } else if (sortType == 'priceOrder') {
      queryParams['priceOrder'] = sortValue; // asc or desc
    }

    final response = await _apiService.get(
      '/api/market/rewards',
      queryParameters: queryParams,
    );

    if (response.data != null && response.data['items'] is List) {
      return (response.data['items'] as List)
          .map((item) => StoreReward.fromJson(item))
          .toList();
    }

    return [];
  }

  Future<void> addMarketItem(String name, int credits, File? image) async {
    try {
      final formData = FormData();

      // Add form fields
      formData.fields.add(MapEntry('Name', name));
      formData.fields.add(MapEntry('Credits', credits.toString()));

      // Add image file if provided
      if (image != null) {
        final fileName = image.path.split('/').last;
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(image.path, filename: fileName),
          ),
        );
      }

      await _apiService.post('/api/market/rewards', data: formData);
    } catch (e) {
      throw Exception('Error adding reward: $e');
    }
  }

  Future<void> deleteMarketItem(int id) async {
    try {
      await _apiService.delete('/api/market/rewards/$id');
    } catch (e) {
      throw Exception('Error deleting reward: $e');
    }
  }

  Future<void> updateMarketItem(
    int id,
    String name,
    int credits,
    File? image,
  ) async {
    try {
      final formData = FormData();

      // Add form fields
      formData.fields.add(MapEntry('Name', name));
      formData.fields.add(MapEntry('Credits', credits.toString()));

      // Add image file (required by API)
      if (image != null) {
        final fileName = image.path.split('/').last;
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(image.path, filename: fileName),
          ),
        );
      } else {
        throw Exception('Image is required for updating reward');
      }

      await _apiService.dio.put(
        '/api/market/rewards/$id',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
    } on DioException catch (e) {
      throw Exception(
        'Error updating reward: ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Error updating reward: $e');
    }
  }

  // Placeholder for orders
  Future<List<OrderModel>> getThisMonthOrders() async {
    final response = await _apiService.get('/api/market/orders/this-month');

    if (response.data is List) {
      return (response.data as List)
          .map((order) => OrderModel.fromJson(order))
          .toList();
    }

    return [];
  }

  Future<List<OrderModel>> getLastMonthOrders() async {
    final response = await _apiService.get('/api/market/orders/last-month');

    if (response.data is List) {
      return (response.data as List)
          .map((order) => OrderModel.fromJson(order))
          .toList();
    }

    return [];
  }

  Future<void> approveOrder(int orderId) async {
    await _apiService.post('/api/market/orders/$orderId/approve');
  }

  Future<void> rejectOrder(int orderId) async {
    await _apiService.post('/api/market/orders/$orderId/reject');
  }

  // Notification methods
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _apiService.get('/api/notifications');

    if (response.data is List) {
      final notifications = (response.data as List)
          .map((notification) => NotificationModel.fromJson(notification))
          .toList();

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
      // Only English title exists, translate to Arabic
      titleAr = await _translationService.translateToArabic(titleEn);
    } else if (titleEn == null && titleAr != null) {
      // Only Arabic title exists, translate to English
      titleEn = await _translationService.translateToEnglish(titleAr);
    }

    // Smart translation for message - preserve item names
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
      // Only English message exists, translate to Arabic with smart parsing
      messageAr = await _smartTranslateMessage(messageEn, 'en', 'ar');
    } else if (messageEn == null && messageAr != null) {
      // Only Arabic message exists, translate to English with smart parsing
      messageEn = await _smartTranslateMessage(messageAr, 'ar', 'en');
    }

    // Return notification with both translations
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

    // Pattern 3: Arabic "لقد تم طلب ItemName من قبل StudentName"
    final arabicOrderPattern = RegExp(r'لقد تم طلب\s+(.+?)\s+من قبل\s+(.+)$');
    final arabicOrderMatch = arabicOrderPattern.firstMatch(message);

    if (arabicOrderMatch != null && toLang == 'en') {
      final itemName = arabicOrderMatch.group(1)?.trim() ?? '';
      final studentName = arabicOrderMatch.group(2)?.trim() ?? '';
      return '$itemName has been ordered from $studentName';
    }

    // Pattern 4: Arabic "لقد طلبت ItemName، هل استلمتها؟"
    final arabicRequestPattern = RegExp(r'لقد طلبت\s+(.+?)،\s*هل استلمتها؟');
    final arabicRequestMatch = arabicRequestPattern.firstMatch(message);

    if (arabicRequestMatch != null && toLang == 'en') {
      final itemName = arabicRequestMatch.group(1)?.trim() ?? '';
      return 'You requested a $itemName, Did you receive it?';
    }

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
}
