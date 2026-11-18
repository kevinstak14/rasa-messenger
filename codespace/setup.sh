#!/usr/bin/env bash
set -euo pipefail
FLUTTER_VERSION="3.24.5"
FLUTTER_DIR="/opt/flutter"
if ! command -v flutter >/dev/null 2>&1; then
  if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
    sudo mkdir -p /opt
    sudo curl -L "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" -o /tmp/flutter.tar.xz
    sudo tar -xf /tmp/flutter.tar.xz -C /opt
    sudo rm /tmp/flutter.tar.xz
  fi
  echo 'export PATH="/opt/flutter/bin:$PATH"' >> "$HOME/.bashrc"
  export PATH="$FLUTTER_DIR/bin:$PATH"
fi
flutter config --no-analytics
# Install Android SDK command-line tools and API 34 if the base image does not provide them.
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
mkdir -p "$ANDROID_HOME/cmdline-tools"
if ! find "$ANDROID_HOME/cmdline-tools" -name sdkmanager -type f 2>/dev/null | grep -q .; then
  sudo apt-get update -y
  sudo apt-get install -y curl unzip
  curl -L "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" -o /tmp/android-cmdline-tools.zip
  mkdir -p /tmp/android-tools "$ANDROID_HOME/cmdline-tools/latest"
  unzip -q /tmp/android-cmdline-tools.zip -d /tmp/android-tools
  mv /tmp/android-tools/cmdline-tools/* "$ANDROID_HOME/cmdline-tools/latest/"
  rm -rf /tmp/android-tools /tmp/android-cmdline-tools.zip
fi
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
yes | sdkmanager --sdk_root="$ANDROID_HOME" --licenses >/dev/null
sdkmanager --sdk_root="$ANDROID_HOME" "platform-tools" "platforms;android-34" "build-tools;34.0.0"
flutter config --android-sdk "$ANDROID_HOME"
yes | flutter doctor --android-licenses >/dev/null || true
cd /workspaces/"$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")"/app 2>/dev/null || cd "$(dirname "$0")/../app"
flutter pub get
# Seed the Android wrapper and platform files when needed; retain our app-specific Gradle config.
if [ ! -f android/gradlew ]; then
  # Keep a copy of the app-specific Android settings while Flutter creates its Gradle wrapper.
  mkdir -p /tmp/rasa-android-xml
  cp -r android/app/src/main/res/xml/* /tmp/rasa-android-xml/
  cp android/app/build.gradle /tmp/rasa-app-build.gradle
  cp android/app/src/main/AndroidManifest.xml /tmp/rasa-AndroidManifest.xml
  flutter create --platforms=android --org com.rasa --project-name rasa .
  cp /tmp/rasa-app-build.gradle android/app/build.gradle
  cp /tmp/rasa-AndroidManifest.xml android/app/src/main/AndroidManifest.xml
  mkdir -p android/app/src/main/res/xml
  cp -r /tmp/rasa-android-xml/* android/app/src/main/res/xml/ 2>/dev/null || true
  echo 'Android wrapper generated.'
fi
