#!/bin/bash
set -euo pipefail

APP_NAME="Parla"
APP_VERSION="${APP_VERSION:-1.1}"
BUILD_NUMBER="${BUILD_NUMBER:-2}"
CONFIGURATION="${CONFIGURATION:-release}"
APP_BUNDLE="${APP_NAME}.app"
CONTENTS="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS}/MacOS"
RESOURCES_DIR="${CONTENTS}/Resources"

echo "Building..."
swift build -c "$CONFIGURATION"
BUILD_DIR="$(swift build -c "$CONFIGURATION" --show-bin-path)"

echo "Creating app bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

cp "$BUILD_DIR/$APP_NAME" "$MACOS_DIR/"

# Copy app icon if available
ICON_SRC="Parla.icns"
if [ -f "$ICON_SRC" ]; then
  cp "$ICON_SRC" "$RESOURCES_DIR/AppIcon.icns"
  echo "Icon copied"
fi

# Copy resource bundle for Bundle.module compatibility
BUNDLE_PATH="$BUILD_DIR/${APP_NAME}_${APP_NAME}.bundle"
if [ -d "$BUNDLE_PATH" ]; then
  cp -R "$BUNDLE_PATH" "$RESOURCES_DIR/"
  echo "Resource bundle copied to Resources/"
fi

# Copy individual resources directly to Resources/ so Bundle.main can find them
# This avoids Bundle.module resolution issues when running from .app
RES_SRC="Sources/App/Resources"
if [ -d "$RES_SRC" ]; then
  for f in "$RES_SRC"/*; do
    filename=$(basename "$f")
    if [ -f "$f" ]; then
      cp "$f" "$RESOURCES_DIR/$filename"
      echo "Copied $filename to Resources/"
    fi
  done
fi

# Create Info.plist
cat > "$CONTENTS/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.parla.app</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleVersion</key>
    <string>${BUILD_NUMBER}</string>
    <key>CFBundleShortVersionString</key>
    <string>${APP_VERSION}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>Parla necesita acceso al micrófono para practicar la pronunciación.</string>
    <key>NSSpeechRecognitionUsageDescription</key>
    <string>Parla necesita reconocer tu voz para evaluar la pronunciación.</string>
</dict>
</plist>
EOF

chmod +x "$MACOS_DIR/$APP_NAME"

# Verify binary is correct
BUILD_HASH=$(md5 -q "$BUILD_DIR/$APP_NAME" 2>/dev/null || echo "none")
BUNDLE_HASH=$(md5 -q "$MACOS_DIR/$APP_NAME" 2>/dev/null || echo "none")
if [ "$BUILD_HASH" != "$BUNDLE_HASH" ]; then
    echo "ERROR: Binary hash mismatch! $BUILD_HASH vs $BUNDLE_HASH"
    exit 1
fi
echo "Binary verified: $BUILD_HASH"

# Code sign for local execution
codesign --force --sign - "$APP_BUNDLE" 2>/dev/null || true

echo ""
echo "✅ ${APP_BUNDLE} created"
echo "Run it: open ${APP_BUNDLE}"
