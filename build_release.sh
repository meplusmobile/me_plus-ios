#!/bin/bash

# Me Plus iOS - Release Build Script for Mac
# This script builds a signed Release IPA

set -e  # Exit on error

echo "🚀 Starting Me Plus iOS Release Build..."
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Clean
echo -e "${BLUE}Step 1/6: Cleaning previous builds...${NC}"
flutter clean
rm -rf build/

# Step 2: Get Flutter packages
echo -e "${BLUE}Step 2/6: Getting Flutter packages...${NC}"
flutter pub get

# Step 3: Install CocoaPods
echo -e "${BLUE}Step 3/6: Installing CocoaPods dependencies...${NC}"
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

# Step 4: Verify environment
echo -e "${BLUE}Step 4/6: Verifying environment...${NC}"
flutter doctor -v

# Step 5: Build Release
echo -e "${BLUE}Step 5/6: Building iOS Release...${NC}"
flutter build ios --release --no-codesign

# Check if build succeeded
if [ ! -d "build/ios/Release-iphoneos/Runner.app" ]; then
    echo -e "${RED}❌ Build failed! Runner.app not found.${NC}"
    exit 1
fi

# Step 6: Create IPA
echo -e "${BLUE}Step 6/6: Creating IPA package...${NC}"
cd build/ios/Release-iphoneos

# Clean old Payload
rm -rf Payload

# Create new Payload
mkdir Payload
cp -r Runner.app Payload/

# Generate IPA filename with timestamp
DATE=$(date +%Y%m%d_%H%M%S)
IPA_NAME="MePlus-Release-${DATE}.ipa"

# Create IPA
zip -r "$IPA_NAME" Payload/

# Move to Desktop
mv "$IPA_NAME" ~/Desktop/

cd ../../../

echo ""
echo -e "${GREEN}✅ Build complete!${NC}"
echo -e "${GREEN}📦 IPA location: ~/Desktop/${IPA_NAME}${NC}"
echo ""
ls -lh ~/Desktop/$IPA_NAME
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Sign the IPA in Xcode or using a signing service"
echo "2. Install on device using:"
echo "   - TestFlight (recommended)"
echo "   - Xcode > Window > Devices and Simulators"
echo "   - Third-party tools (AltStore, Sideloadly, etc.)"
echo ""
echo -e "${GREEN}Done! 🎉${NC}"
