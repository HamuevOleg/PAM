# Lab 1: Dart and Flutter for iOS

Hamuev Oleg, CR-232

- `dart_exercises/exercises.dart`: exercises E1-E6 from the assignment.
- `dart_exercises/check.dart`: additional checks.
- `hello_pam/`: the standard Flutter counter app for iOS.
- `evidence/`: a screenshot from the simulator.
- `Reports/`: the Word/PDF report and defense guide.

## Run

```sh
dart run dart_exercises/exercises.dart
dart run dart_exercises/check.dart
open -a Simulator
cd hello_pam
flutter pub get --enforce-lockfile
flutter devices
flutter run
```

If several devices are available, select an iPhone Simulator or use
`flutter run -d <device-id>`. In the Flutter terminal, press `r` for hot reload,
`R` for hot restart, or `q` to quit.

The semester project topic is RunBaza. See `RunBaza_specification.txt` and the report appendix.

## Environment and checks

Flutter 3.47.0 / Dart 3.13. iOS development requires macOS, Xcode and iOS Simulator.
Add the Flutter SDK to PATH. After `flutter pub get`, you can open
`hello_pam/ios/Runner.xcworkspace` in Xcode and select an iPhone simulator.

From `hello_pam`:

```sh
flutter analyze --fatal-infos
flutter test
flutter build ios --simulator --debug --no-codesign
```
