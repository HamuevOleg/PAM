# Lab 4: State and repositories

RunBaza continues in `Lab2/run_baza`. The Lab 4 branch is
`lab/4-state-repository`. The earlier navigation and registration versions remain
on their Lab 3 branches.

## What changed

- Five shared ChangeNotifier models own races, the personal plan, driver offers,
  passenger requests and the runner profile.
- Typed CRUD repository interfaces return `Future<Result<T>>`. The mock source
  keeps data in memory, assigns IDs and waits 800 ms per operation.
- All data screens handle loading, data and retryable errors. Unknown IDs have a
  separate not-found screen.
- Participation creates or updates a plan entry. Removing it requires confirmation.
  Details, the plan badge, the list and profile statistics update together.
- Driver and passenger forms create records and update the relevant list.
- The profile has an editable runner card, avatar colors, biography, home city,
  pace, preferred distance, season planning goal and app-wide theme selection.
- A failure switch in Profile / Diagnostics demonstrates failed reads and writes.
  Failed submissions keep their fields; the user can retry without retyping.

The season figures describe planned races and kilometers, not completed training.
Login and registration remain local validation. There is no backend authentication,
booking, notification delivery or disk persistence in this lab. Restarting the app
restores the seed data, including profile settings.

## Run on iOS

```sh
cd ~/Desktop/PAM/Lab2/run_baza
flutter pub get --enforce-lockfile
open -a Simulator
flutter devices
flutter run -d <simulator-id>
```

For Xcode, prepare dependencies with Flutter, then open
`Lab2/run_baza/ios/Runner.xcworkspace`. Select an iOS Simulator and run Runner.
The screen code is in `lib/screens`, not in the native Runner folder.

## Architecture

| Layer | Files | Responsibility |
| --- | --- | --- |
| Views | `lib/screens`, `lib/widgets` | Render state, validate local form fields, dispatch actions |
| State | `lib/models` | Loading and saving flags, errors, immutable list access, notifications |
| Contracts | `lib/data/*_repository.dart`, `repository.dart`, `result.dart` | Typed asynchronous CRUD with explicit success or failure |
| Mock source | `lib/data/mock_repositories.dart` | Memory, generated IDs, delay and controlled failures |
| Composition | `lib/main.dart` | Choose sources and inject them into model constructors |

Only the mock repository imports `mock_data.dart`. The profile diagnostics control
is the documented exception that knows the mock implementation. A future HTTP
repository can replace the source in `main.dart`; the diagnostic switch can then
be removed. Models and screens continue to use the same contracts.

`context.watch` subscribes during build. `context.read` dispatches actions from
callbacks. The plan badge uses `Consumer<PlanModel>`. Form controllers, filters
and the diagnostic switch remain local widget state.

## Checks

```sh
flutter analyze --fatal-infos
flutter test
flutter build ios --simulator --debug --no-codesign
flutter drive --driver=test_driver/lab4_driver.dart \
  --target=integration_test/lab4_test.dart -d <simulator-id>
```

The unit/widget suite includes repository CRUD, generated IDs, immutable results,
notifications, overlapping loads, pending writes, cross-screen updates, form
validation, error recovery and responsive layouts. The Lab 4 iOS scenario captures
20 screenshots in `Lab4/evidence/ios`.

To check seed isolation:

```sh
rg -n 'mock_data' lib/screens lib/widgets lib/models
```

Expected result: no matches. See `evidence/verification.txt` for the recorded run.

## Documents

- [Report in Word](Reports/PAM_L4_HamuevOleg.docx)
- [Report in PDF](Reports/PAM_L4_HamuevOleg.pdf)
- [Defense guide in PDF](Reports/PAM_L4_Guide_HamuevOleg.pdf)

The guide explains the demonstration, code locations and likely defense questions.
