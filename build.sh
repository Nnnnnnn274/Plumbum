#!/bin/bash

# build.sh - Build script for plumbum IPA
# This script builds the iOS app and creates an IPA file

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="plumbum"
SCHEME_NAME="plumbum"
CONFIGURATION="Release"
ARCHIVE_PATH="./build/${PROJECT_NAME}.xcarchive"
IPA_OUTPUT_PATH="./build"
DERIVED_DATA_PATH="./build/DerivedData"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Building ${PROJECT_NAME} IPA${NC}"
echo -e "${GREEN}========================================${NC}"

# Clean previous builds
echo -e "${YELLOW}Cleaning previous builds...${NC}"
rm -rf "${ARCHIVE_PATH}"
rm -rf "${DERIVED_DATA_PATH}"
rm -rf "${IPA_OUTPUT_PATH}/${PROJECT_NAME}.ipa"

# Build XPF subproject
echo -e "${YELLOW}Building XPF subproject...${NC}"
cd plumbum/XPF
make all || {
    echo -e "${RED}Failed to build XPF${NC}"
    exit 1
}
cd ../..

# Build the app
echo -e "${YELLOW}Building ${PROJECT_NAME}...${NC}"
xcodebuild archive \
    -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME_NAME}" \
    -configuration "${CONFIGURATION}" \
    -archivePath "${ARCHIVE_PATH}" \
    -derivedDataPath "${DERIVED_DATA_PATH}" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    || {
    echo -e "${RED}Failed to build ${PROJECT_NAME}${NC}"
    exit 1
    }

# Export IPA
echo -e "${YELLOW}Exporting IPA...${NC}"
xcodebuild -exportArchive \
    -archivePath "${ARCHIVE_PATH}" \
    -exportPath "${IPA_OUTPUT_PATH}" \
    -exportOptionsPlist ./exportOptions.plist \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    || {
    echo -e "${RED}Failed to export IPA${NC}"
    exit 1
    }

# Move IPA to output directory
if [ -f "${IPA_OUTPUT_PATH}/${PROJECT_NAME}.app/${PROJECT_NAME}" ]; then
    echo -e "${YELLOW}Creating IPA manually...${NC}"
    cd "${IPA_OUTPUT_PATH}"
    zip -r "${PROJECT_NAME}.ipa" "${PROJECT_NAME}.app"
    cd ..
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Build successful!${NC}"
echo -e "${GREEN}IPA location: ${IPA_OUTPUT_PATH}/${PROJECT_NAME}.ipa${NC}"
echo -e "${GREEN}========================================${NC}"
