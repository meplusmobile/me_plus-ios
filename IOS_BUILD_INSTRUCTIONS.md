# 🔧 حل مشكلة الكراش - iOS Crash Fix

## ✅ التغييرات المُطبقة:

### 1. إصلاح AppDelegate.swift
**المشكلة:** SharedPreferencesPlugin كان يُسجل قبل تجهيز Flutter engine
**الحل:** تم تغيير الترتيب ليتم تسجيل الـ plugins بعد تهيئة Flutter

### 2. إضافة Error Handling
- أضفت try-catch في جميع عمليات SharedPreferences
- أضفت error boundary في main.dart
- أضفت تسجيل الأخطاء للتتبع

### 3. تحسين Info.plist
- أضفت Privacy Manifest لـ iOS 17+
- أضفت UserDefaults privacy reason
- أضفت Background modes

### 4. Podfile Configuration
- أنشأت Podfile جديد بإعدادات صحيحة
- ضبطت iOS deployment target على 13.0
- أضفت إصلاحات لـ Xcode 14+

## 🚀 خطوات البناء على macOS:

```bash
# 1. تنظيف المشروع
flutter clean
rm -rf ios/Pods ios/Podfile.lock

# 2. تحديث الـ dependencies
flutter pub get

# 3. تثبيت CocoaPods (إذا لم يكن مثبت)
sudo gem install cocoapods

# 4. تثبيت iOS dependencies
cd ios
pod install
cd ..

# 5. تشغيل التطبيق
flutter run
```

## 🔥 إذا استمر الكراش:

### Option 1: Clean Build
```bash
flutter clean
cd ios
rm -rf Pods Podfile.lock .symlinks
pod deintegrate
pod install
cd ..
flutter run
```

### Option 2: Reset Simulator
```bash
# افتح Xcode
# Device > Erase All Content and Settings
# ثم شغل التطبيق من جديد
```

### Option 3: Check Xcode Settings
1. افتح `ios/Runner.xcworkspace` في Xcode
2. تأكد من:
   - Build Settings > iOS Deployment Target = 13.0
   - Signing & Capabilities > Team مضبوط
   - DEVELOPMENT_TEAM = 9LTW6KU59G

## 📱 للتشغيل على جهاز حقيقي:

```bash
# 1. وصل الجهاز
# 2. تأكد من Trust Certificate
# 3. شغل:
flutter run -d <device-id>

# لعرض الأجهزة المتاحة:
flutter devices
```

## ⚠️ ملاحظات مهمة:

1. **Windows:** لا يمكن بناء iOS على Windows، تحتاج Mac
2. **CocoaPods:** يجب تثبيته لبناء iOS
3. **Xcode:** يجب تثبيت Xcode 14+ من App Store
4. **Certificates:** تأكد من صلاحية شهادات المطور

## 🐛 إذا ظهرت أخطاء أخرى:

### SharedPreferences Error
```bash
flutter pub cache repair
flutter clean
flutter pub get
cd ios && pod install
```

### Signing Error
1. افتح Xcode
2. Runner target > Signing & Capabilities
3. اختر Team الصحيح
4. حدد "Automatically manage signing"

### Google Sign-In Error
- تأكد من GoogleService-Info.plist موجود
- تأكد من Client ID صحيح في Info.plist
- راجع Google Cloud Console settings

## 📞 للمساعدة:
إذا واجهت مشاكل، ابعث:
1. الرسالة الكاملة للخطأ
2. نسخة Xcode
3. نسخة Flutter: `flutter --version`
4. معلومات الجهاز: `flutter doctor -v`
