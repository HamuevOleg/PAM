# Lab 3: RunBaza

Navigation, forms and validation in the existing **Lab2/run_baza** Flutter app.
iOS is the demonstration platform. The original Lab 2 version is preserved on
`lab/2-runbaza-ui`. Lab 3 is developed on `lab/3-navigation-forms` and merged into
`main` through a pull request.

## Run

```sh
cd Lab2/run_baza
flutter pub get --enforce-lockfile
open -a Simulator
flutter devices
flutter run -d <simulator-id>
```

In Xcode, open `Lab2/run_baza/ios/Runner.xcworkspace`, select Runner and an iPhone
simulator. UI code is in `Lab2/run_baza/lib`.

Login accepts a syntactically valid email and a password of at least 6 characters,
for example `runner@example.com` / `runbaza26`. This validates the local form;
it does not check a server account or save the password.

## Features

- `go_router`, `MaterialApp.router` and routes with string IDs.
- Five independent tabs using `StatefulShellRoute.indexedStack` and `NavigationBar`.
- Search by name, city and distance, plus a country filter.
- Forms for login, race participation, driver offers, passenger requests and profile editing.
- `Form`, `GlobalKey<FormState>`, validators, input filters and controllers with `dispose`.
- `SnackBar` after validation and `AlertDialog<bool>` before logout.
- Handling of unknown paths, IDs and distances.
- Light and dark themes, city artwork and animations from Lab 2.

Race and transfer data is fixed. Submitting these forms does not create a database
record, book a seat or send a network request. Persistence and backend authentication
are planned for a later lab.

## Checks

```sh
cd Lab2/run_baza
flutter analyze --fatal-infos
flutter test
flutter build ios --simulator --debug --no-codesign
flutter drive --driver=test_driver/lab3_driver.dart \
  --target=integration_test/lab3_test.dart -d <simulator-id>
```

100 unit/widget tests cover validation, tab stacks and state, invalid routes,
dialogs, animations, widths from 320 to 430, both themes and text scaling up to 160%.
The iOS integration scenario saves screenshots in `Lab3/evidence/ios`.

## Documents

- [PDF report](Reports/PAM_L3_HamuevOleg.pdf)
- [Editable Word report](Reports/PAM_L3_HamuevOleg.docx)
- [PDF defense guide](Reports/PAM_L3_Guide_HamuevOleg.pdf)

The report includes routes, router.dart, screenshots of all navigation branches,
different IDs, form errors, validation rules, SnackBar, logout confirmation and
commit history. The guide covers Mac setup, the demonstration sequence, code
explanations and questions.

Design reference: Samepace, main at `438e942`, 11 October 2026. The UI is written
in Flutter. Vue/Worker source and server configuration from the reference are
not included in this repository.
