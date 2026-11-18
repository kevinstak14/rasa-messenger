#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/app"
flutter pub get
flutter build apk --release --target-platform android-arm64
APK="build/app/outputs/flutter-apk/app-release.apk"
mkdir -p "$ROOT"
cp "$APK" "$ROOT/rasa.apk"
echo ""
echo "✅ APK ساخته شد: $APK"
echo "👉 فایل rasa.apk در ریشه پروژه را از Explorer دانلود کن."
