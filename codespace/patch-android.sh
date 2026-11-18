#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# Flutter create generates the Gradle wrapper. Restore the project's required Android settings afterwards.
cp "$ROOT/app/android/settings.gradle" "$ROOT/app/android/build.gradle" "$ROOT/app/android/gradle.properties" "$ROOT/app/android/" 2>/dev/null || true
# Android-specific files are committed in this repository; this script is a validation hook.
grep -q "abiFilters 'arm64-v8a'" "$ROOT/app/android/app/build.gradle"
grep -q 'networkSecurityConfig' "$ROOT/app/android/app/src/main/AndroidManifest.xml"
echo 'Android config checked.'
