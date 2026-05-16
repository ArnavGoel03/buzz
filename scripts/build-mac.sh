#!/usr/bin/env bash
# build-mac.sh — produce a runnable Buzz.app + Buzz.zip + Buzz.dmg for ad-hoc distribution.
# No App Store, no Developer ID required. Per DEVELOP_RULES §5: ship .zip for auto-update,
# .dmg for human download; right-click → Open first time because the build is ad-hoc-signed.
#
# Usage:
#   BUILD_VERSION=1.0.0 scripts/build-mac.sh
#
# Outputs (in dist/mac/):
#   Buzz-<version>.app
#   Buzz-<version>.zip
#   Buzz-<version>.dmg
#
# Requirements: xcodegen, xcodebuild, hdiutil (built into macOS), optional `create-dmg`
# for a prettier DMG. Falls back to plain hdiutil if create-dmg isn't installed.

set -euo pipefail

cd "$(dirname "$0")/.."

VERSION="${BUILD_VERSION:-1.0.0}"
BUILD_NUMBER="${BUILD_NUMBER:-$(date +%Y%m%d%H%M)}"
OUT="dist/mac"
APP_NAME="Buzz"
SCHEME="Buzz"
BUNDLE_ID="com.arnavgoel.buzz"

echo "▶ Buzz Mac build · v${VERSION} · build ${BUILD_NUMBER}"

# 1. Regenerate the Xcode project from project.yml so a fresh checkout works.
if ! command -v xcodegen >/dev/null 2>&1; then
  echo "✖ xcodegen not found. Install via Brewfile: brew bundle"
  exit 1
fi
xcodegen generate

# 2. Build for macOS, exporting an unsigned .app archive into ${OUT}.
rm -rf "${OUT}"
mkdir -p "${OUT}"

ARCHIVE_PATH="${OUT}/${APP_NAME}.xcarchive"
EXPORT_PATH="${OUT}/export"

xcodebuild \
  -project "${APP_NAME}.xcodeproj" \
  -scheme "${SCHEME}" \
  -configuration Release \
  -destination "generic/platform=macOS" \
  -archivePath "${ARCHIVE_PATH}" \
  MARKETING_VERSION="${VERSION}" \
  CURRENT_PROJECT_VERSION="${BUILD_NUMBER}" \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  archive

# 3. Export the .app from the archive. ExportOptions for ad-hoc / non-store distribution.
cat > "${OUT}/ExportOptions.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>          <string>mac-application</string>
    <key>signingStyle</key>    <string>manual</string>
    <key>destination</key>     <string>export</string>
</dict>
</plist>
EOF

xcodebuild \
  -exportArchive \
  -archivePath "${ARCHIVE_PATH}" \
  -exportPath  "${EXPORT_PATH}" \
  -exportOptionsPlist "${OUT}/ExportOptions.plist"

APP_PATH="${EXPORT_PATH}/${APP_NAME}.app"
if [[ ! -d "${APP_PATH}" ]]; then
  echo "✖ Build produced no .app at ${APP_PATH}"
  exit 1
fi

# 4. Ad-hoc sign so Gatekeeper doesn't outright refuse the binary. Users will still
#    get the "unidentified developer" prompt on first launch — that's expected for
#    ad-hoc distribution and documented in the release notes.
codesign --force --deep --sign - --options runtime "${APP_PATH}"

# 5. Stage versioned artifacts.
VERSIONED_APP="${OUT}/${APP_NAME}-${VERSION}.app"
rm -rf "${VERSIONED_APP}"
ditto "${APP_PATH}" "${VERSIONED_APP}"

# 6. Zip — used by Sparkle-style auto-update when it lands.
ZIP_PATH="${OUT}/${APP_NAME}-${VERSION}.zip"
(cd "${OUT}" && ditto -c -k --sequesterRsrc --keepParent "${APP_NAME}-${VERSION}.app" "${APP_NAME}-${VERSION}.zip")
echo "✓ Wrote ${ZIP_PATH}"

# 7. DMG — recommended human download path. Use create-dmg if available, plain hdiutil otherwise.
DMG_PATH="${OUT}/${APP_NAME}-${VERSION}.dmg"
if command -v create-dmg >/dev/null 2>&1; then
  rm -f "${DMG_PATH}"
  create-dmg \
    --volname "${APP_NAME} ${VERSION}" \
    --window-size 600 380 \
    --icon-size 100 \
    --icon "${APP_NAME}-${VERSION}.app" 160 190 \
    --app-drop-link 440 190 \
    "${DMG_PATH}" \
    "${VERSIONED_APP}"
else
  hdiutil create -volname "${APP_NAME} ${VERSION}" \
    -srcfolder "${VERSIONED_APP}" \
    -ov -format UDZO "${DMG_PATH}"
fi
echo "✓ Wrote ${DMG_PATH}"

# 8. Summary.
echo
echo "▶ Done. Distributables in ${OUT}/:"
ls -lh "${OUT}/${APP_NAME}-${VERSION}".{app,zip,dmg} 2>/dev/null | awk '{print "    " $9 "  (" $5 ")"}'
echo
echo "▶ First-launch instruction for users:"
echo "    Right-click the app → Open → confirm. (Ad-hoc-signed; Developer-ID notarization"
echo "    arrives at v1.x.0 per DEVELOP_RULES §5.)"
