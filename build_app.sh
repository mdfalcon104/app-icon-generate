#!/bin/bash

echo "🔨 Building App Icon Generator..."

# Build the app in release mode
swift build -c release

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "📦 Creating app bundle..."

# Create app bundle structure
APP_NAME="App Icon Generator"
APP_DIR="${APP_NAME}.app"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Copy the built executable
cp .build/release/AppIconGenerator "$APP_DIR/Contents/MacOS/$APP_NAME"
chmod +x "$APP_DIR/Contents/MacOS/$APP_NAME"

# Create Info.plist
cat > "$APP_DIR/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleExecutable</key>
	<string>App Icon Generator</string>
	<key>CFBundleIconFile</key>
	<string>AppIcon</string>
	<key>CFBundleIdentifier</key>
	<string>com.appicongen.AppIconGenerator</string>
	<key>CFBundleName</key>
	<string>App Icon Generator</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>LSMinimumSystemVersion</key>
	<string>13.0</string>
	<key>NSHighResolutionCapable</key>
	<true/>
</dict>
</plist>
PLIST

# Copy icon if it exists
if [ -f /tmp/AppIcon.icns ]; then
    cp /tmp/AppIcon.icns "$APP_DIR/Contents/Resources/AppIcon.icns"
fi

# Refresh icon cache
touch "$APP_DIR"

echo "✅ Build complete!"
echo "📍 Created: $APP_DIR"
echo ""
echo "🚀 Opening app..."
open "$APP_DIR"
