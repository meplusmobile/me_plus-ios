# Me Plus iOS App

Flutter application with iOS deployment support.

## 📋 Prerequisites

### For Development (Mac)
- **macOS** 12.0 or later
- **Xcode** 15.0 or later ([Download from App Store](https://apps.apple.com/app/xcode/id497799835))
- **Flutter SDK** 3.19.0 or later ([Install Flutter](https://docs.flutter.dev/get-started/install/macos))
- **CocoaPods** ([Install guide](https://cocoapods.org/))

### For CI/CD (Any platform)
- **Codemagic** account (builds on cloud Mac)
- **GitHub** repository access

---

## 🚀 Quick Start (Mac)

### 1. Clone Repository
```bash
git clone https://github.com/meplusmobile/me_plus-ios.git
cd me_plus-ios
```

### 2. Install Dependencies
```bash
# Get Flutter packages
flutter pub get

# Install iOS dependencies
cd ios
pod install
cd ..
```

### 3. Build & Run

#### Debug Build (for testing)
```bash
flutter run -d <device_id>
```

#### Release Build (unsigned IPA)
```bash
flutter build ios --release --no-codesign

# Create IPA manually
cd build/ios/Release-iphoneos
mkdir Payload
cp -r Runner.app Payload/
zip -r Runner-Release.ipa Payload/
```

#### Release Build (signed for App Store)
```bash
# Open Xcode workspace
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select Runner target
# 2. Go to Signing & Capabilities
# 3. Select your Team (Apple Developer Account)
# 4. Build > Archive
# 5. Distribute App > App Store Connect
```

---

## 🔧 Configuration

### iOS Settings
- **Bundle ID**: `meplusapp`
- **Deployment Target**: iOS 13.0
- **Development Team**: Configure in Xcode (Signing & Capabilities)

### App Permissions (Info.plist)
- Camera access
- Photo library access
- Network access
- Google Sign-In

---

## 🏗️ Build from Mac (Complete Guide)

### Step 1: Setup Xcode
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Accept Xcode license
sudo xcodebuild -license accept
```

### Step 2: Install Flutter
```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

### Step 3: Install CocoaPods
```bash
sudo gem install cocoapods
pod setup
```

### Step 4: Build Project
```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Install iOS pods
cd ios && pod install && cd ..

# Run Flutter Doctor to verify setup
flutter doctor -v

# Build release IPA
flutter build ios --release
```

### Step 5: Code Signing (for distribution)
```bash
# Open project in Xcode
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select Runner project (left sidebar)
# 2. Select Runner target
# 3. Go to "Signing & Capabilities" tab
# 4. Enable "Automatically manage signing"
# 5. Select your Team from dropdown
# 6. Build > Archive (⌘+B to build first)
# 7. Window > Organizer
# 8. Select archive > Distribute App
# 9. Choose distribution method:
#    - App Store Connect (for TestFlight/App Store)
#    - Ad Hoc (for internal testing)
#    - Development (for local devices)
```

---

## 🔄 CI/CD with Codemagic

### Automatic Builds
Push to `main` branch triggers automatic build on Codemagic.

### Manual Build
1. Go to [Codemagic Dashboard](https://codemagic.io/apps)
2. Select `me_plus-ios` project
3. Click "Start new build"
4. Download IPA from Artifacts

### Codemagic Configuration
The `codemagic.yaml` file is configured to:
- Build **Release** mode (not debug)
- Generate **unsigned IPA** (sign externally or in Xcode)
- Send email notification on build completion

---

## 🐛 Troubleshooting

### CocoaPods Issues
```bash
# Clear CocoaPods cache
cd ios
rm -rf Pods Podfile.lock
pod deintegrate
pod install
cd ..
```

### Flutter Issues
```bash
# Clear Flutter cache
flutter clean
flutter pub get

# Reinstall
rm -rf ~/.flutter
git clone https://github.com/flutter/flutter.git -b stable ~/.flutter
```

### Xcode Build Errors
```bash
# Clean Xcode derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Reset Xcode
xcodebuild clean
```

### Signing Issues
- Verify Apple Developer account is active
- Check Bundle ID matches App Store Connect
- Ensure provisioning profiles are up to date
- In Xcode: Product > Clean Build Folder (⌘+Shift+K)

---

## 📱 Testing

### Simulator
```bash
flutter run -d "iPhone 15 Pro"
```

### Physical Device
```bash
# List devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

### TestFlight
1. Build archive in Xcode
2. Upload to App Store Connect
3. Submit for TestFlight review
4. Add internal/external testers

---

## 📦 Dependencies

Main packages:
- `dio` - HTTP client
- `provider` - State management
- `go_router` - Navigation
- `google_sign_in` - Google authentication
- `image_picker` - Camera/gallery access
- `shared_preferences` - Local storage
- `path_provider` - File system access

See `pubspec.yaml` for complete list.

---

## 🔑 Important Notes

### For Mac Users
- You can build **signed** release IPA directly
- Full Xcode integration available
- Can upload to App Store Connect
- Can test on simulators and devices

### For Windows Users
- Use **Codemagic** for cloud builds
- Download unsigned IPA from Codemagic
- Sign IPA using online services or Mac
- Install via AltStore/Sideloadly/3uTools

### App Version
Current version: `1.0.0+24` (in `pubspec.yaml`)
- Update version before each release
- Build number auto-increments

---

## 📞 Support

- **Repository**: https://github.com/meplusmobile/me_plus-ios
- **Developer**: fadihamad40984@gmail.com

---

## 📄 License

Private project - All rights reserved.
