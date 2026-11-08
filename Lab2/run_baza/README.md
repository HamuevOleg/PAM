# RunBaza for iOS

This is the original Lab 2 Flutter project, continued through Lab 5 without copying
or recreating the app. See [Lab 5](../../Lab5/README.md) for backend setup,
authentication, run commands, tests and documentation.
[Lab 4](../../Lab4/README.md) describes the earlier state and repository layer.
[Lab 3](../../Lab3/README.md) describes navigation and validation at that stage. The static Lab 2 version
is available on the `lab/2-runbaza-ui` branch.

```sh
flutter pub get --enforce-lockfile
flutter run -d <simulator-id>
```

Start `Lab2/server` first with `pnpm start`. The iOS Simulator connects to
`http://127.0.0.1:8080`. Register an account in the app; there is no preset login.

Main UI: `lib/screens/`. Navigation: `lib/router.dart`.
Xcode workspace: `ios/Runner.xcworkspace`.
