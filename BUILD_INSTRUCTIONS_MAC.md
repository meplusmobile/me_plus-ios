# 🍎 تعليمات البناء على Mac - Build Instructions

## للمطور اللي عنده Mac

---

## ⚡ البداية السريعة

### 1. تثبيت الأدوات الأساسية

```bash
# تثبيت Xcode من App Store أو:
xcode-select --install

# تثبيت Homebrew (إذا مش موجود)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# تثبيت Flutter
brew install --cask flutter

# تثبيت CocoaPods
sudo gem install cocoapods
```

### 2. تحميل المشروع

```bash
git clone https://github.com/meplusmobile/me_plus-ios.git
cd me_plus-ios
```

### 3. تثبيت Dependencies

```bash
# Flutter packages
flutter pub get

# iOS dependencies
cd ios
pod install
cd ..
```

---

## 🔨 طرق البناء

### الطريقة 1: بناء Debug (للتجربة)

```bash
# تشغيل على جهاز متصل أو Simulator
flutter run
```

### الطريقة 2: بناء Release بدون توقيع (Unsigned)

```bash
# بناء Release mode
flutter build ios --release --no-codesign

# إنشاء IPA يدوياً
cd build/ios/Release-iphoneos
mkdir Payload
cp -r Runner.app Payload/
zip -r ~/Desktop/Runner-Release.ipa Payload/
cd ../../../

echo "✅ IPA جاهز على سطح المكتب!"
```

### الطريقة 3: بناء Release مع توقيع (Signed - للنشر)

```bash
# 1. افتح Xcode Workspace
open ios/Runner.xcworkspace

# 2. في Xcode، اتبع الخطوات:
```

#### في Xcode:

1. **اختر Target:**
   - من الـ sidebar الأيسر، اضغط على `Runner` (project)
   - اختر `Runner` (target)

2. **إعداد Signing:**
   - اضغط تبويب `Signing & Capabilities`
   - فعّل ✅ `Automatically manage signing`
   - اختر `Team` من القائمة (حسابك في Apple Developer)
   - تأكد أن Bundle ID = `meplusapp`

3. **بناء Archive:**
   ```
   Menu Bar > Product > Archive
   ```
   (أو اضغط ⌘+B للتأكد من البناء أولاً)

4. **Organizer:**
   - راح يفتح Organizer تلقائياً
   - أو: `Window > Organizer`
   - اختر Archive الجديد
   - اضغط `Distribute App`

5. **اختر وجهة التوزيع:**
   - **App Store Connect** → للنشر على TestFlight أو App Store
   - **Ad Hoc** → للتوزيع الداخلي (max 100 devices)
   - **Development** → للتجربة على أجهزتك فقط
   - **Export** → حفظ IPA على جهازك

---

## 🎯 بناء لأول مرة (خطوة بخطوة)

```bash
# 1. تنظيف البناءات القديمة
flutter clean

# 2. تحميل packages
flutter pub get

# 3. التأكد من صحة البيئة
flutter doctor -v

# 4. تثبيت pods (iOS dependencies)
cd ios
rm -rf Pods Podfile.lock  # حذف القديم
pod install                # تثبيت من جديد
cd ..

# 5. بناء Release
flutter build ios --release --no-codesign

# 6. إنشاء IPA
cd build/ios/Release-iphoneos
mkdir -p Payload
cp -r Runner.app Payload/
zip -r ~/Desktop/me-plus-$(date +%Y%m%d).ipa Payload/
cd ../../../

# 7. عرض النتيجة
ls -lh ~/Desktop/*.ipa
```

---

## 🔧 حل المشاكل الشائعة

### مشكلة 1: CocoaPods Errors

```bash
# حذف كل شي وإعادة تثبيت
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all
pod install
cd ..
```

### مشكلة 2: Xcode Build Failed

```bash
# تنظيف Derived Data
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# تنظيف build folder
flutter clean

# إعادة البناء
flutter pub get
cd ios && pod install && cd ..
flutter build ios --release --no-codesign
```

### مشكلة 3: Signing Issues

في Xcode:
1. `Product > Clean Build Folder` (⌘+Shift+K)
2. اذهب إلى `Signing & Capabilities`
3. أعد اختيار Team
4. أعد بناء Archive

### مشكلة 4: Flutter Doctor Issues

```bash
# تحديث Flutter
flutter upgrade

# إصلاح التبعيات
flutter doctor --android-licenses  # إذا كنت تستخدم Android
flutter doctor -v
```

---

## 📱 التجربة على الأجهزة

### Simulator:

```bash
# فتح Simulator
open -a Simulator

# عرض قائمة الأجهزة المتاحة
xcrun simctl list devices

# تشغيل التطبيق
flutter run -d "iPhone 15 Pro"
```

### جهاز فيزيائي (iPhone/iPad):

```bash
# 1. وصّل الجهاز بـ USB
# 2. عرض الأجهزة
flutter devices

# 3. تشغيل على الجهاز
flutter run -d <device_id>
```

**ملاحظة:** أول مرة راح يطلب منك "Trust this computer" على الجهاز.

---

## 🚀 النشر على TestFlight

### الخطوات:

1. **بناء Archive في Xcode:**
   ```
   open ios/Runner.xcworkspace
   Product > Archive
   ```

2. **رفع إلى App Store Connect:**
   - من Organizer: `Distribute App`
   - اختر `App Store Connect`
   - اتبع الخطوات

3. **إضافة TestFlight Testers:**
   - اذهب إلى [App Store Connect](https://appstoreconnect.apple.com)
   - اختر التطبيق
   - تبويب `TestFlight`
   - أضف Internal/External Testers

4. **إرسال لـ Beta Review:**
   - أضف وصف للتحديث
   - أرسل للمراجعة
   - عادة يأخذ 1-2 يوم

---

## 📦 إنشاء IPA موقّع بسرعة

### سكريبت كامل:

```bash
#!/bin/bash
# save as: build_release.sh

echo "🚀 Building Me Plus iOS Release..."

# Clean
flutter clean
flutter pub get

# CocoaPods
cd ios
pod install
cd ..

# Build
flutter build ios --release --no-codesign

# Create IPA
cd build/ios/Release-iphoneos
rm -rf Payload
mkdir Payload
cp -r Runner.app Payload/

DATE=$(date +%Y%m%d_%H%M%S)
IPA_NAME="MePlus-Release-${DATE}.ipa"

zip -r ~/Desktop/$IPA_NAME Payload/
cd ../../../

echo "✅ IPA created: ~/Desktop/$IPA_NAME"
ls -lh ~/Desktop/$IPA_NAME
```

**استخدام:**
```bash
chmod +x build_release.sh
./build_release.sh
```

---

## 🔐 ملاحظات هامة عن الـ Signing

### لديك 3 خيارات:

#### 1. **Development Signing** (للتجربة فقط)
- مجاني
- يعمل على أجهزتك فقط
- صالح لمدة 7 أيام
- يتطلب إعادة توقيع

#### 2. **Ad Hoc Distribution** (تجربة داخلية)
- يتطلب Apple Developer Account ($99/year)
- يعمل على max 100 device
- صالح لمدة سنة
- للاختبار الداخلي

#### 3. **App Store Distribution** (النشر الرسمي)
- يتطلب Apple Developer Account
- للنشر على TestFlight/App Store
- عدد غير محدود من المستخدمين

---

## 📊 معلومات المشروع

- **Bundle ID:** `meplusapp`
- **Version:** `1.0.0+24` (في pubspec.yaml)
- **Deployment Target:** iOS 13.0
- **Development Team:** يجب إضافته في Xcode

### قبل كل Release:

```bash
# حدّث رقم الإصدار في pubspec.yaml
version: 1.0.0+25  # زوّد build number

# أو من command line:
flutter build ios --release --build-number=25
```

---

## 🎁 Scripts مفيدة

### تنظيف شامل:

```bash
#!/bin/bash
echo "🧹 Deep clean..."
flutter clean
cd ios
rm -rf Pods Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData/*
pod cache clean --all
pod install
cd ..
echo "✅ Clean complete!"
```

### فحص الـ build size:

```bash
# بعد البناء
cd build/ios/Release-iphoneos/Runner.app
du -sh .
cd ../../../..
```

---

## 💡 نصائح احترافية

### 1. استخدم Xcode schemes:
```
Product > Scheme > Edit Scheme
اختلف الإعدادات بين Debug و Release
```

### 2. فعّل Bitcode (اختياري):
```
في Build Settings:
Enable Bitcode = YES
```

### 3. راقب warnings:
```bash
flutter analyze
```

### 4. اعمل version control:
```bash
git tag v1.0.0+24
git push --tags
```

---

## 📞 الدعم

إذا واجهت مشكلة:

1. **شيك Flutter Doctor:**
   ```bash
   flutter doctor -v
   ```

2. **شيك Xcode:**
   ```bash
   xcodebuild -version
   ```

3. **شيك CocoaPods:**
   ```bash
   pod --version
   ```

4. **راجع الـ logs:**
   ```bash
   flutter run --verbose
   ```

---

## ✅ Checklist قبل النشر

- [ ] تحديث version في `pubspec.yaml`
- [ ] اختبار على Simulator
- [ ] اختبار على جهاز فيزيائي
- [ ] مراجعة الـ permissions في `Info.plist`
- [ ] تأكد من صحة Bundle ID
- [ ] اختبار Google Sign-In
- [ ] اختبار Camera/Photos access
- [ ] تشغيل `flutter analyze`
- [ ] مراجعة App Icon
- [ ] إنشاء screenshots للـ App Store
- [ ] كتابة Release Notes

---

**بالتوفيق! 🚀**

إذا احتجت مساعدة: fadihamad40984@gmail.com
