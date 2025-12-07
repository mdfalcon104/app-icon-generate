#!/bin/bash

# Build and run the App Icon Generator

echo "🚀 Building App Icon Generator..."

# Build the app
swift build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "🎨 Starting App Icon Generator..."
    swift run
else
    echo "❌ Build failed!"
    exit 1
fi
