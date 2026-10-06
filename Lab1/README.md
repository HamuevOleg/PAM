# Лабораторная 1 — Hamuev Oleg, CR-232

- `dart_exercises/exercises.dart` — E1–E6 с примерами из задания.
- `dart_exercises/check.dart` — дополнительные проверки.
- `hello_pam/` — стандартное Flutter-приложение счётчика для iOS.
- `evidence/` — снимок приложения в симуляторе.
- `Reports/` — отчёт Word/PDF и инструкция для защиты.

## Запуск

```sh
dart run dart_exercises/exercises.dart
dart run dart_exercises/check.dart
open -a Simulator
cd hello_pam
flutter pub get --enforce-lockfile
flutter devices
flutter run
```

Если устройств несколько, выберите iPhone Simulator из списка или запустите `flutter run -d <device-id>`.
В терминале Flutter: r — hot reload, R — hot restart, q — выход.
Тема проекта: RunBaza; спецификация находится в приложении к отчёту.

## Среда и проверки

Flutter 3.47.0 / Dart 3.13. Для iOS нужны macOS, Xcode и iOS Simulator.
Добавьте Flutter SDK в PATH. После `flutter pub get` можно открыть
`hello_pam/ios/Runner.xcworkspace` в Xcode и выбрать симулятор iPhone.

```sh
cd hello_pam
flutter analyze --fatal-infos
flutter test
flutter build ios --simulator --debug --no-codesign
```
