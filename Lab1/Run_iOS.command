#!/bin/zsh
set -e
cd "$(dirname "$0")/hello_pam"
if ! command -v flutter >/dev/null 2>&1; then
  printf 'Добавьте Flutter SDK в PATH и запустите файл снова.\n'
  exit 1
fi
open -a Simulator
flutter pub get --enforce-lockfile
if [[ -n "${IOS_DEVICE_ID:-}" ]]; then
  flutter run -d "$IOS_DEVICE_ID"
else
  flutter run
fi
