# RunBaza: Lab 2 for iOS

Static Material 3 screens based on `PROJECT_SPEC.md`.
Student: Hamuev Oleg, CR-232. Instructor: Leah A.

## Run

Open Terminal in this folder, next to `pubspec.yaml`:

```sh
open -a Simulator
flutter pub get --enforce-lockfile
flutter devices
flutter run -d <simulator-id>
```

You can also run `../Run_iOS.command`. In Xcode, open
`ios/Runner.xcworkspace`, select an iPhone simulator, then choose Run from the Product menu.

## Screens

1. Home / Board: the next race, statistics, four city and distance previews, and the season list.
2. Race Index: eight races grouped by season, with search and five filter controls.
3. Race Details: information about a selected race and its registration button.
4. Transfer: six driver offers and six passenger requests for Orheiul Vechi Trail.
5. My Plan: six saved events and reminder dates.
6. Settings: city, appearance and notifications.
7. Login: two text fields and a button, without authentication or validation.
8. Distance: a distance page with an animated illustration.

Navigate using the home buttons, profile icon, race cards and back button.

## Lab 2 scope

Screens use StatelessWidget. AnimatedRoute is a separate StatefulWidget that
controls the drawing animation. Mock data is in `lib/data/mock_data.dart`.
Search, filters, registration, seat requests, settings and reminders show the
layout of planned features. They do not change or save data. Login returns to Home.
The light and dark palettes follow the system theme with ThemeMode.system.

Dates, fees, names and links are fictional. The scenario date is 27 September 2026.
The example.com links do not register anyone for a race. CustomPainter draws the
illustrations without a network connection, WebView or external fonts.

## Source files

- `lib/main.dart`: app entry point and theme.
- `lib/screens/`: eight screens, including the distance page.
- `lib/widgets/`: shared cards, badges, panels and illustrations.
- `lib/data/`: models and mock data.
- `test/`: layout, navigation, data and animation tests.

## Design

Reference: https://github.com/dmitriaigenkiv/runbaza-app, commit c6ba2dd.
The Flutter adaptation uses the cover/detail layout, cut corners, emblems,
platform.css palettes and industrial.css typography. See `DESIGN_CREDITS.md`.

Home is in `lib/screens/home_screen.dart`. Distance artwork is in
`lib/widgets/race_motif.dart`. Search and filters remain mockups for Lab 2.
No real registration or booking takes place.

## Distance pages and animation

Select a preview on Home or a distance in Race Details. The page shows a cover,
description, start details, preparation notes and a link to transfers for the
same event. Times and fees come from that event.

- `lib/screens/distance_screen.dart`: distance page.
- `lib/widgets/distance_option.dart`: distance selection button.
- `lib/data/distance_profile.dart`: distance names and descriptions.
- `lib/widgets/animated_route.dart`: drawing with PathMetric.extractPath.

The line draws over 3.4 seconds, with a moving marker, checkpoints and a finish.
Use the replay button to restart it. This is decorative artwork, not a GPS route.
Only the CustomPainter repaints. iOS Reduce Motion displays the complete line
without animation, and the ticker is disposed when the page closes.

## Cities and countries

RaceCountry and RaceMotif describe each event. `motifForRace` selects artwork
by event rather than distance alone. Covers, previews and animations share it.

| Location | Country | Illustration |
| --- | --- | --- |
| Iasi | Romania | Palace of Culture |
| Bucharest | Romania | Romanian Athenaeum |
| Chisinau, city race | Moldova | Arch; Stefan cel Mare for the half marathon |
| Chisinau, winter race | Moldova | Valea Morilor park steps |
| Trebujeni | Moldova | Old Orhei |
| Cricova | Moldova | Grapevine |
| Lozova | Moldova | Codrii forest |
| Vadul lui Voda | Moldova | Dniester riverbanks |

The four Home previews show Cricova 5 km, Iasi 10 km, Old Orhei 21.1 km and
Bucharest 42.2 km. Each preview opens the same event it displays. All drawings
use Flutter paths. They are stylized landmarks, not measured race courses.
Changing the city restarts the animation.

## Checks and environment

Flutter 3.47.0 / Dart 3.13. Add Flutter to PATH and select your simulator with
`flutter devices`.

```sh
flutter analyze --fatal-infos
flutter test
flutter build ios --simulator --debug --no-codesign
```

The Lab 2 suite contains 76 tests covering navigation, all eight events, nine
illustrations, animation progress, replay, Reduce Motion and disposal. Layout
checks cover widths of 320, 390 and 430, both themes and text scaling up to 160%.
CI checks formatting, analysis, tests and an unsigned iOS Simulator build.
Reports are in `../Reports/`.
