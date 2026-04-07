#!/bin/bash
set -e

APP_NAME="Light Up My Life"
BUILD_DIR=".build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"

echo "Building Light Up My Life..."

# Clean previous build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Compile all Swift sources
swiftc -O \
    -o "$BUILD_DIR/LightUpMyLife" \
    Sources/LightUpMyLife/*.swift \
    -framework Cocoa \
    -framework MetalKit \
    -framework Metal \
    -framework SwiftUI

# Create .app bundle
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"
cp "$BUILD_DIR/LightUpMyLife" "$APP_DIR/Contents/MacOS/LightUpMyLife"
cp Info.plist "$APP_DIR/Contents/Info.plist"

# Ad-hoc code sign
codesign --force --deep --sign - "$APP_DIR"

echo ""
echo "Build complete: $APP_DIR"
echo "Run: open \"$APP_DIR\""
