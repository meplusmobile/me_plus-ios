import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Image Picker Helper with proper iOS error handling
class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery with error handling
  static Future<File?> pickFromGallery(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error picking image from gallery: $e');
      
      if (context.mounted) {
        _showErrorDialog(
          context,
          'خطأ في اختيار الصورة',
          'تعذر الوصول إلى معرض الصور. يرجى التحقق من الأذونات.',
        );
      }
      return null;
    }
  }

  /// Pick image from camera with error handling
  static Future<File?> pickFromCamera(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error taking photo: $e');
      
      if (context.mounted) {
        _showErrorDialog(
          context,
          'خطأ في التقاط الصورة',
          'تعذر الوصول إلى الكاميرا. يرجى التحقق من الأذونات.',
        );
      }
      return null;
    }
  }

  /// Show image source selection dialog
  static Future<File?> showImageSourceDialog(BuildContext context) async {
    return showModalBottomSheet<File>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                const Text(
                  'اختر مصدر الصورة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 20),
                
                // Camera Option
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: Color(0xFFF7941D),
                    size: 28,
                  ),
                  title: const Text(
                    'الكاميرا',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final file = await pickFromCamera(context);
                    if (context.mounted && file != null) {
                      Navigator.pop(context, file);
                    }
                  },
                ),
                
                const Divider(height: 1),
                
                // Gallery Option
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: Color(0xFFF7941D),
                    size: 28,
                  ),
                  title: const Text(
                    'معرض الصور',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final file = await pickFromGallery(context);
                    if (context.mounted && file != null) {
                      Navigator.pop(context, file);
                    }
                  },
                ),
                
                const SizedBox(height: 10),
                
                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Show error dialog
  static void _showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'حسناً',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
