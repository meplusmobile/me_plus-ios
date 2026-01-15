#!/bin/bash

# Me Plus iOS - Xcode Archive & Upload Script
# This script opens Xcode for manual signing and archiving

set -e

echo "🚀 Preparing Xcode for Release Build..."
echo ""

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

# Step 1: Clean and prepare
echo -e "${BLUE}Step 1/4: Cleaning and preparing...${NC}"
flutter clean
flutter pub get

# Step 2: Install pods
echo -e "${BLUE}Step 2/4: Installing CocoaPods...${NC}"
cd ios
pod install
cd ..

# Step 3: Open Xcode
echo -e "${BLUE}Step 3/4: Opening Xcode...${NC}"
open ios/Runner.xcworkspace

echo ""
echo -e "${GREEN}✅ Xcode is opening!${NC}"
echo ""
echo -e "${BLUE}In Xcode, follow these steps:${NC}"
echo ""
echo "1. Select 'Runner' target (top left, near Play button)"
echo "2. Go to 'Signing & Capabilities' tab"
echo "3. Enable '✓ Automatically manage signing'"
echo "4. Select your Team from dropdown"
echo "5. Build > Archive (or Product > Archive)"
echo "6. Wait for archive to complete"
echo "7. Window > Organizer (or it opens automatically)"
echo "8. Select your archive > 'Distribute App'"
echo "9. Choose distribution method:"
echo "   • App Store Connect (for TestFlight/App Store)"
echo "   • Ad Hoc (for internal testing, max 100 devices)"
echo "   • Development (for your devices only)"
echo "   • Export (save IPA to disk)"
echo ""
echo -e "${GREEN}Ready to build! 🎉${NC}"
