#!/bin/bash

echo "📦 Creating release package..."

# Clean and build
swift build -c release

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# Create app bundle
APP_NAME="App Icon Generator"
APP_DIR="${APP_NAME}.app"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Copy executable
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

# Copy icon
if [ -f /tmp/AppIcon.icns ]; then
    cp /tmp/AppIcon.icns "$APP_DIR/Contents/Resources/AppIcon.icns"
else
    # Generate icon if not exists
    if [ -f create_icon.py ]; then
        python3 create_icon.py 2>/dev/null
        iconutil -c icns /tmp/AppIcon.iconset -o /tmp/AppIcon.icns 2>/dev/null
        cp /tmp/AppIcon.icns "$APP_DIR/Contents/Resources/AppIcon.icns" 2>/dev/null
    fi
fi

# Create release directory
RELEASE_DIR="release"
rm -rf "$RELEASE_DIR"
mkdir -p "$RELEASE_DIR"

# Copy app to release
cp -R "$APP_DIR" "$RELEASE_DIR/"

# Create README for release
cat > "$RELEASE_DIR/README.txt" <<'README'
App Icon Generator v1.0
=======================

INSTALLATION
------------
1. Copy "App Icon Generator.app" to your Applications folder (optional)
2. Double-click to run

IMPORTANT - First Time Opening
-------------------------------
If you see a security warning:
1. Right-click (or Control+click) on "App Icon Generator.app"
2. Select "Open" from the menu
3. Click "Open" in the dialog
4. You only need to do this once

HOW TO USE
----------
1. Click the drop zone or drag & drop an image
2. Select corner radius (0, 4, 8, 16, or custom)
3. Optional: Check "Also generate Logo.imageset"
4. Click "Generate Icons"
5. Click "Reveal in Finder" to see your icons

The app will create AppIcon.appiconset (and optionally Logo.imageset) 
on your Desktop, ready to use in Xcode.

REQUIREMENTS
------------
- macOS 13.0 or later

For more information, visit:
https://github.com/yourusername/app-icon-generate
README

# Create ZIP archive
cd "$RELEASE_DIR"
zip -r "../AppIconGenerator-v1.0.zip" . -q
cd ..

echo ""
echo "✅ Release package created!"
echo "📍 Location: AppIconGenerator-v1.0.zip"
echo "📦 Size: $(du -h AppIconGenerator-v1.0.zip | cut -f1)"
echo ""
echo "Contents:"
echo "  - App Icon Generator.app"
echo "  - README.txt (installation instructions)"
echo ""
echo "🚀 Ready to distribute!"
