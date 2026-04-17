#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/build/OptTab.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"

cd "$ROOT_DIR"
swift build -c release

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR"
cp ".build/release/OptTab" "$MACOS_DIR/OptTab"

cat > "$CONTENTS_DIR/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>OptTab</string>
    <key>CFBundleExecutable</key>
    <string>OptTab</string>
    <key>CFBundleIdentifier</key>
    <string>dev.local.OptTab</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>OptTab</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>0.1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

if [[ -z "${CODESIGN_IDENTITY:-}" ]]; then
  GIT_EMAIL="$(git config user.email 2>/dev/null || true)"
  if [[ -n "$GIT_EMAIL" ]]; then
    CODESIGN_IDENTITY="$(
      security find-identity -v -p codesigning 2>/dev/null \
        | awk -F '"' -v email="$GIT_EMAIL" '/Developer ID Application|Apple Development/ && index($2, email) { print $2; exit }'
    )"
  fi
fi

if [[ -z "${CODESIGN_IDENTITY:-}" ]]; then
  USER_NAME="${USER:-$(id -un)}"
  if [[ -n "$USER_NAME" ]]; then
    CODESIGN_IDENTITY="$(
      security find-identity -v -p codesigning 2>/dev/null \
        | awk -F '"' -v user="$USER_NAME" '/Developer ID Application|Apple Development/ && index($2, user) { print $2; exit }'
    )"
  fi
fi

if [[ -z "${CODESIGN_IDENTITY:-}" ]]; then
  CODESIGN_IDENTITY="$(
    security find-identity -v -p codesigning 2>/dev/null \
      | awk -F '"' '/Developer ID Application|Apple Development/ { print $2; exit }'
  )"
fi

if [[ -n "$CODESIGN_IDENTITY" ]]; then
  echo "Signing with: $CODESIGN_IDENTITY" >&2
  codesign --force --sign "$CODESIGN_IDENTITY" "$APP_DIR"
else
  echo "No code signing identity found; falling back to ad-hoc signing." >&2
  codesign --force --sign - "$APP_DIR"
fi

echo "$APP_DIR"
