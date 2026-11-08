# Lab 5 - Backend integration

RunBaza continues in `Lab2/run_baza`. Its backend is in `Lab2/server`.
The application targets iOS. The original TypeScript/Hono server replaces the
course language examples and persists data in SQLite.

## Run

Terminal 1, with Node.js 24+ and pnpm 11.25.0 installed:

```sh
cd ~/Desktop/PAM/Lab2/server
pnpm install --frozen-lockfile
pnpm start
```

Terminal 2:

```sh
cd ~/Desktop/PAM/Lab2/run_baza
flutter pub get --enforce-lockfile
open -a Simulator
flutter devices
flutter run -d <iphone-simulator-id>
```

The iOS Simulator uses `http://127.0.0.1:8080`. Register a new account in the app.
There is no preset login. To use a different address, pass
`--dart-define=API_BASE_URL=http://your-address:8080` when building or running.
For a physical iPhone, localhost refers to the phone; use the Mac's LAN address
and appropriate iOS local-network/transport settings instead.

Xcode workspace: `Lab2/run_baza/ios/Runner.xcworkspace`. Keep the API terminal
running when launching Runner from Xcode. Dart UI code remains under `lib/screens`.

## What changed

- Registration and login now call the API. Passwords are not stored by Flutter.
- JWT is saved in shared preferences, restored at startup and removed on logout
  or an authenticated HTTP 401.
- Typed HTTP repositories implement the existing CRUD contract. Transport,
  status and JSON errors become `Err` results with Russian user messages.
- Races, plans, driver offers, passenger requests and profiles are stored in
  SQLite. The API also includes the baseline notes and multipart file routes.
- Catalog search and country filtering execute on the server. Scrolling loads
  the initial 28 demonstration races in pages of 20 and 8.
- Runtime mocks and the diagnostic switch are removed. Isolated fakes remain
  under `test/support` for deterministic unit/widget tests.
- API tests run in CI alongside Flutter checks and the iOS Simulator build.

The code-only source replacement checkpoint is `fa96d09`. At this checkpoint,
data screens and state models have no changes relative to Lab 4 (`4c687e9`).
The later pagination commit changes the catalog UI and collection model to add
new behavior. These are separate changes for separate requirements.

```sh
git diff --stat 4c687e9 fa96d09 -- Lab2/run_baza/lib/screens Lab2/run_baza/lib/models
git log --oneline c2b88af^..HEAD
```

## Verification

```sh
cd ~/Desktop/PAM/Lab2/server
pnpm check
pnpm test
cd ../run_baza
flutter analyze
flutter test
```

The server suite runs 58 HTTP checks and a separate database restart test.
These are project tests, not the course's 37-check conformance suite; the latter
was not available and has not been claimed as passed.

For the real iOS scenario, start the isolated test API first:

```sh
cd ~/Desktop/PAM/Lab2/server
pnpm exec tsx test/ios_controller.ts
```

Then, in another terminal:

```sh
cd ~/Desktop/PAM/Lab2/run_baza
flutter drive --driver=test_driver/lab5_driver.dart --target=integration_test/lab5_test.dart --dart-define=API_BASE_URL=http://127.0.0.1:8090 -d <iphone-simulator-id>
```

The controller binds only to localhost and uses separate ports 8090/8091 and a
separate SQLite file. Its stop/start/rotate commands are test fixtures, not
production routes. Screenshots are written to `Lab5/evidence/ios`.

## Defense materials

- [Report PDF](Reports/PAM_L5_HamuevOleg.pdf)
- [Editable report](Reports/PAM_L5_HamuevOleg.docx)
- [Defense guide](Reports/PAM_L5_Guide_HamuevOleg.pdf)
- [Source replacement diff](evidence/source-swap-diff.txt)
- [Backend tests](evidence/backend-tests.txt)
- [Curl session](evidence/curl-session.txt)
- [API contract and scope](../Lab2/server/README.md)

This stage does not implement offline data caching, public carpool booking,
password recovery, production deployment or push notifications. Upload is
implemented and tested at the API level. The current theme uses generated route
artwork, so no user-facing image picker is required for this stage.
