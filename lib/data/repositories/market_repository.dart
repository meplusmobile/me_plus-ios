import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:me_plus/data/services/api_service.dart';
import 'package:me_plus/data/services/token_storage_service.dart';
import 'package:me_plus/data/models/user_profile.dart';
import 'package:me_plus/data/models/store_model.dart';
import 'package:me_plus/data/models/activity_model.dart';
import 'package:me_plus/data/models/order_model.dart';
import 'package:me_plus/core/services/translation_service.dart';

class MarketRepository {
  final ApiService _apiService = ApiService();
  final TranslationService _translationService = TranslationService();
  final TokenStorageService _tokenStorage = TokenStorageService();

  Future<UserProfile> getMarketProfile() async {
    final response = await _apiService.get('/market/profile');
    if (!response.success) {
      throw Exception(response.error ?? 'Error fetching market profile');
    }
    return UserProfile.fromJson(response.data);
  }

  Future<UserProfile> updateMarketProfile(Map<String, dynamic> data) async {
    final imagePath = data.remove('imagePath') as String?;
    
    if (imagePath != null) {
      // Use multipart request for image upload
      await _updateProfileWithImage(data, imagePath);
    } else {
      final response = await _apiService.put('/api/me', data: data);
      if (!response.success) {
        throw Exception(response.error ?? 'Error updating market profile');
      }
    }
    return await getMarketProfile();
  }

  Future<void> _updateProfileWithImage(Map<String, dynamic> data, String imagePath) async {
    final token = await _tokenStorage.getToken();
    final uri = Uri.parse('${ApiService.baseUrl}/api/me');
    
    final request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = 'Bearer $token';
    
    data.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    final fileName = imagePath.split('/').last;
    final extension = fileName.split('.').last.toLowerCase();
    final mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';
    
    request.files.add(await http.MultipartFile.fromPath(
      'Image',
      imagePath,
      filename: fileName,
      contentType: MediaType.parse(mimeType),
    ));

    final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  Future<List<StoreReward>> getMarketItems({
    String sortType = 'sortBy',
    String sortValue = 'oldest',
  }) async {
    final Map<String, dynamic> queryParams = {'pageSize': 35, 'pageNumber': 1};

    if (sortType == 'sortBy') {
      queryParams['sortBy'] = sortValue;
    } else if (sortType == 'priceOrder') {
      queryParams['priceOrder'] = sortValue;
    }

    final response = await _apiService.get(
      '/api/market/rewards',
      queryParameters: queryParams,
    );

    if (!response.success) {
      debugPrint('Failed to get market items: ${response.error}');
      return [];
    }

    if (response.data != null && response.data['items'] is List) {
      return (response.data['items'] as List)
          .map((item) => StoreReward.fromJson(item))
          .toList();
    }

    return [];
  }

  Future<void> addMarketItem(String name, int credits, File? image) async {
    try {
      final token = await _tokenStorage.getToken();
      final uri = Uri.parse('${ApiService.baseUrl}/api/market/rewards');
      
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      
      request.fields['Name'] = name;
      request.fields['Credits'] = credits.toString();

      if (image != null) {
        final fileName = image.path.split('/').last;
        final extension = fileName.split('.').last.toLowerCase();
        final mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';
        
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          image.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ));
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to add reward: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding reward: $e');
    }
  }

  Future<void> deleteMarketItem(int id) async {
    final response = await _apiService.delete('/api/market/rewards/$id');
    if (!response.success) {
      throw Exception(response.error ?? 'Error deleting reward');
    }
  }

  Future<void> updateMarketItem(
    int id,
    String name,
    int credits,
    File? image,
  ) async {
    try {
      if (image == null) {
        throw Exception('Image is required for updating reward');
      }

      final token = await _tokenStorage.getToken();
      final uri = Uri.parse('${ApiService.baseUrl}/api/market/rewards/$id');
      
      final request = http.MultipartRequest('PUT', uri);
      request.headers['Authorization'] = 'Bearer $token';
      
      request.fields['Name'] = name;
      request.fields['Credits'] = credits.toString();

      final fileName = image.path.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();
      final mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';
      
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      ));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to update reward: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating reward: $e');
    }
  }

  Future<List<OrderModel>> getThisMonthOrders() async {
    final response = await _apiService.get('/api/market/orders/this-month');

    if (!response.success) {
      debugPrint('Failed to get this month orders: ${response.error}');
      return [];
    }

    if (response.data is List) {
      return (response.data as List)
          .map((order) => OrderModel.fromJson(order))
          .toList();
    }

    return [];
  }

  Future<List<OrderModel>> getLastMonthOrders() async {
    final response = await _apiService.get('/api/market/orders/last-month');

    if (!response.success) {
      debugPrint('Failed to get last month orders: ${response.error}');
      return [];
    }

    if (response.data is List) {
      return (response.data as List)
          .map((order) => OrderModel.fromJson(order))
          .toList();
    }

    return [];
  }

  Future<void> approveOrder(int orderId) async {
    final response = await _apiService.post('/api/market/orders/$orderId/approve');
    if (!response.success) {
      throw Exception(response.error ?? 'Failed to approve order');
    }
  }

  Future<void> rejectOrder(int orderId) async {
    final response = await _apiService.post('/api/market/orders/$orderId/reject');
    if (!response.success) {
      throw Exception(response.error ?? 'Failed to reject order');
    }
  }

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _apiService.get('/api/notifications');

    if (!response.success) {
      debugPrint('Failed to get notifications: ${response.error}');
      return [];
    }

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
    final orderPattern = RegExp(r'^(.+?)\s+has been ordered from\s+(.+)$');
    final orderMatch = orderPattern.firstMatch(message);

    if (orderMatch != null) {
      final itemName = orderMatch.group(1)?.trim() ?? '';
      final studentName = orderMatch.group(2)?.trim() ?? '';

      if (toLang == 'ar') {
        return 'لقد تم طلب $itemName من قبل $studentName';
      }
    }

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

    final arabicOrderPattern = RegExp(r'لقد تم طلب\s+(.+?)\s+من قبل\s+(.+)$');
    final arabicOrderMatch = arabicOrderPattern.firstMatch(message);

    if (arabicOrderMatch != null && toLang == 'en') {
      final itemName = arabicOrderMatch.group(1)?.trim() ?? '';
      final studentName = arabicOrderMatch.group(2)?.trim() ?? '';
      return '$itemName has been ordered from $studentName';
    }

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
    final response = await _apiService.post('/api/notifications/mark-as-read/$notificationId');
    if (!response.success) {
      debugPrint('Failed to mark notification as read: ${response.error}');
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    final response = await _apiService.delete('/api/notifications/$notificationId');
    if (!response.success) {
      debugPrint('Failed to delete notification: ${response.error}');
    }
  }
}
