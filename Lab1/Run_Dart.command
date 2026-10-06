#!/bin/zsh
set -e
cd "$(dirname "$0")"
if ! command -v dart >/dev/null 2>&1; then
  printf "Добавьте Dart или Flutter SDK в PATH.\n"
  exit 1
fi
dart run dart_exercises/exercises.dart
dart run dart_exercises/check.dart
printf '\nНажмите Enter для закрытия...'
read -r reply
