#!/data/data/com.termux/files/usr/bin/bash
# راه‌اندازی سرور رسا در Termux
set -e
cd "$(dirname "$0")"
echo "در حال بررسی پیش‌نیازها..."
command -v node >/dev/null 2>&1 || { echo "ابتدا اجرا کن: pkg install nodejs-lts"; exit 1; }
if [ ! -d node_modules ]; then
  echo "در حال نصب کتابخانه‌های سرور (بار اول ممکن است چند دقیقه طول بکشد)..."
  npm install
fi
mkdir -p public/uploads
node seed.js
printf "\nرسا آماده است: http://127.0.0.1:3000\nبرای توقف Ctrl+C را بزن.\n\n"
node server.js
