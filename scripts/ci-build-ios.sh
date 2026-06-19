#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_PATH="$PROJECT_ROOT/NutsNews/NutsNews.xcodeproj"
SCHEME="NutsNews"
LOG_DIR="$PROJECT_ROOT/build-logs"
LOG_FILE="$LOG_DIR/ios-ci-build.log"

mkdir -p "$LOG_DIR"

if [ ! -d "$PROJECT_PATH" ]; then
  echo "ERROR: Xcode project not found at: $PROJECT_PATH"
  exit 1
fi

echo "NutsNews iOS CI build"
echo "Project root: $PROJECT_ROOT"
echo "Project path: $PROJECT_PATH"
echo "Scheme: $SCHEME"
echo ""

echo "Xcode path:"
xcode-select -p

echo ""
echo "Xcode version:"
xcodebuild -version

echo ""
echo "Available SDKs:"
xcodebuild -showsdks

echo ""
echo "Building NutsNews for generic iOS Simulator..."

xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  clean build 2>&1 | tee "$LOG_FILE"

echo ""
echo "Build succeeded. Log saved to: $LOG_FILE"
