#!/bin/bash

echo "🎨 Creating App Icon Generator.app..."

# Create app bundle structure
APP_DIR="App Icon Generator.app"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Create the launcher script
cat > "$APP_DIR/Contents/MacOS/launcher" << 'EOF'
#!/bin/bash

# Get the app bundle directory
BUNDLE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"
SOURCE_DIR="$( cd "$BUNDLE_DIR/.." && pwd )"

# Change to source directory and run
cd "$SOURCE_DIR"
exec swift run AppIconGenerator
EOF

chmod +x "$APP_DIR/Contents/MacOS/launcher"

# Create Info.plist
cat > "$APP_DIR/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>launcher</string>
	<key>CFBundleIconFile</key>
	<string>AppIcon</string>
	<key>CFBundleIdentifier</key>
	<string>com.appicongen.AppIconGenerator</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>App Icon Generator</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSMinimumSystemVersion</key>
	<string>13.0</string>
	<key>NSHighResolutionCapable</key>
	<true/>
</dict>
</plist>
EOF

# Create a simple icon using sips (if available)
# Create a temporary icon
cat > /tmp/create_icon.py << 'PYEOF'
from PIL import Image, ImageDraw, ImageFont
import os

# Create icon
size = 512
img = Image.new('RGB', (size, size), color='#007AFF')
draw = ImageDraw.Draw(img)

# Draw a simple app icon design
# Rounded rectangle background
draw.rounded_rectangle([(40, 40), (size-40, size-40)], radius=80, fill='#0051D5')

# Draw "AI" text
try:
    font = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', 200)
except:
    font = None

text = "AI"
if font:
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    x = (size - text_width) / 2
    y = (size - text_height) / 2 - 20
    draw.text((x, y), text, fill='white', font=font)

img.save('/tmp/app_icon.png')
print("Icon created!")
PYEOF

# Try to create icon with Python
if command -v python3 &> /dev/null; then
    if python3 -c "import PIL" 2>/dev/null; then
        python3 /tmp/create_icon.py
        if [ -f /tmp/app_icon.png ]; then
            # Convert to icns using sips
            mkdir -p /tmp/AppIcon.iconset
            sips -z 512 512 /tmp/app_icon.png --out /tmp/AppIcon.iconset/icon_512x512.png
            sips -z 256 256 /tmp/app_icon.png --out /tmp/AppIcon.iconset/icon_256x256.png
            sips -z 128 128 /tmp/app_icon.png --out /tmp/AppIcon.iconset/icon_128x128.png
            sips -z 64 64 /tmp/app_icon.png --out /tmp/AppIcon.iconset/icon_32x32@2x.png
            sips -z 32 32 /tmp/app_icon.png --out /tmp/AppIcon.iconset/icon_32x32.png
            sips -z 32 32 /tmp/app_icon.png --out /tmp/AppIcon.iconset/icon_16x16@2x.png
            sips -z 16 16 /tmp/app_icon.png --out /tmp/AppIcon.iconset/icon_16x16.png
            iconutil -c icns /tmp/AppIcon.iconset -o "$APP_DIR/Contents/Resources/AppIcon.icns"
            rm -rf /tmp/AppIcon.iconset /tmp/app_icon.png
        fi
    fi
fi

echo "✅ App created successfully!"
echo "📍 Location: $(pwd)/$APP_DIR"
echo ""
echo "🚀 Double-click '$APP_DIR' to run the app!"
