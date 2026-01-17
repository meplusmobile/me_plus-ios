# iOS Build Instructions

## Critical iOS Fixes Applied (Build 25)

### Issues Fixed
1. **Plugin Initialization Race Condition** - "Unable to connect to server" error was actually a plugin timing issue
2. **GoogleFonts Path Provider Crash** - Removed all GoogleFonts to prevent path_provider crash during startup
3. **Error Masking** - Errors now propagate properly instead of being hidden
4. **Security Hardening** - Tightened iOS App Transport Security to HTTPS-only

### Changes Made

#### 1. Splash Screen Timing Fix
**File:** `lib/presentation/screens/splash_check_screen.dart`
- Added `WidgetsBinding.instance.addPostFrameCallback()` to delay plugin calls
- iOS requires first frame to render before native plugin channels are ready
- Added proper error handling with fallback to login screen

#### 2. Remove Error Hiding
**File:** `lib/data/services/token_storage_service.dart`
- Removed try-catch blocks from all getter methods
- Exceptions now propagate to caller for proper handling
- Only non-critical operations (clearAuthData, saveRememberMe) keep try-catch

#### 3. Replace GoogleFonts with System Fonts
**Files:** 25+ files across `lib/presentation/`
- Replaced `GoogleFonts.poppins()` with `const TextStyle(fontFamily: 'Poppins')`
- Replaced `GoogleFonts.inter()` with `const TextStyle(fontFamily: 'Inter')`
- Removed `google_fonts` package from `pubspec.yaml`
- iOS will use system fonts (San Francisco) when Inter/Poppins not available

#### 4. Tighten iOS Security
**File:** `ios/Runner/Info.plist`
- Changed NSAppTransportSecurity to allow only specific Azure domain
- Enforced HTTPS-only connections
- Removed overly permissive NSAllowsArbitraryLoads

---

## Build Instructions for Mac

### Prerequisites
- Xcode installed (latest stable version)
- Flutter SDK (should match Windows version: 3.38.3)
- CocoaPods installed

### Clean Build Process

```bash
# 1. Pull latest changes
git pull origin main

# 2. Clean previous builds
flutter clean
cd ios
rm -rf Pods Podfile.lock build
cd ..

# 3. Get Flutter dependencies
flutter pub get

# 4. Install iOS pods
cd ios
pod install
cd ..

# 5. Build iOS release
flutter build ios --release

# 6. Open in Xcode
open ios/Runner.xcworkspace
```

### In Xcode

1. **Clean Build Folder**: Product → Clean Build Folder (⇧⌘K)
2. **Select Device**: Choose your iPad or iPhone from device dropdown
3. **Run**: Click the play button or press ⌘R

### Expected Results

✅ App launches without plugin errors  
✅ Splash screen displays and completes auth check  
✅ Login screen renders correctly with system fonts  
✅ Login API call succeeds  
✅ Token is saved successfully  
✅ Navigation to home screen works based on role  

### Troubleshooting

**If you see "Unable to connect to server":**
- This was the original error - should be FIXED now
- If it still occurs, check Console.app for actual error messages
- Look for `PlatformException` or `channel-error` in logs

**If fonts look different:**
- This is expected - using system fonts now instead of downloaded fonts
- iOS will use San Francisco font as fallback for Inter
- Should look native and consistent with iOS design

**If build fails:**
- Ensure CocoaPods is up to date: `sudo gem install cocoapods`
- Try `pod repo update` before `pod install`
- Check iOS deployment target is set to 13.0 in Xcode

### Alternative: Codemagic Build

If Codemagic is configured:
1. Changes pushed to `main` will trigger automatic build
2. Download unsigned IPA from artifacts
3. Sign via external service (if needed)
4. Install on device via Xcode or third-party tool

---

## Technical Details

### Why This Fix Works

**Root Cause:** iOS plugin channels (SharedPreferences, PathProvider) are not ready until after the first frame renders. Calling them in `initState()` causes a crash that manifested as a network error.

**The Fix:**
1. **Timing**: Use `postFrameCallback` to delay plugin calls
2. **Fonts**: Remove GoogleFonts which requires PathProvider during initialization
3. **Errors**: Let exceptions surface instead of hiding them as null
4. **Security**: Proper HTTPS configuration

### Why Android Worked

- Android plugin architecture is more tolerant of early initialization
- PathProvider and SharedPreferences ready sooner
- Roboto font available immediately (no download needed)
- Less strict about native channel timing

---

## Version Info

- **Build:** 1.0.0+25
- **Bundle ID:** meplusapp
- **API:** https://meplus3-hjfehnfpfyg2gyau.israelcentral-01.azurewebsites.net
- **Deployment Target:** iOS 13.0+
- **Tested On:** iPad12,1 (iOS 26.2)

---

## Questions?

Contact: Fadi (Windows) or Mac builder
Repository: https://github.com/meplusmobile/me_plus-ios
