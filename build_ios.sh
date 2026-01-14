#!/bin/bash

# Me Plus iOS Build Script
# This script prepares and builds the iOS app

echo "🚀 Starting Me Plus iOS build process..."

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: iOS builds require macOS"
    echo "Please run this on a Mac computer"
    exit 1
fi

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed"
    echo "Install from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check CocoaPods installation
if ! command -v pod &> /dev/null; then
    echo "⚠️  CocoaPods is not installed"
    echo "Installing CocoaPods..."
    sudo gem install cocoapods
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf ios/.symlinks

# Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Install iOS dependencies
echo "📦 Installing iOS pods..."
cd ios
pod install --repo-update
cd ..

# Build for iOS
echo "🔨 Building iOS app..."
flutter build ios --release

echo "✅ Build complete!"
echo ""
echo "📱 To run on device/simulator:"
echo "   flutter run -d <device-id>"
echo ""
echo "📤 To create IPA for TestFlight:"
echo "   1. Open ios/Runner.xcworkspace in Xcode"
echo "   2. Product > Archive"
echo "   3. Distribute App > TestFlight"
