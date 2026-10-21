#!/bin/zsh
set -e
cd "$(dirname "$0")"
if ! command -v dart >/dev/null 2>&1; then
  printf "Add the Dart or Flutter SDK to PATH.\n"
  exit 1
fi
dart run dart_exercises/exercises.dart
dart run dart_exercises/check.dart
printf '\nPress Enter to close...'
read -r reply
