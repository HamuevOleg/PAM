# RunBaza — Race Calendar & Carpooling App for Runners

**Course:** PAM (Programarea Aplicațiilor Mobile / Mobile Application Programming)
**Student:** Hamuev Oleg
**Group:** CR-232
**Platform:** iOS (Flutter / Dart)

## Topic

RunBaza is a mobile application for amateur runners in Moldova and nearby Romanian cities
(Iași, București). It collects all upcoming running races — road marathons, half marathons,
trail runs, wine-cellar runs, night runs, charity fun runs — into a single, always up-to-date
calendar, and helps runners get to out-of-town starts together by sharing car seats.

Today this information is scattered across organizer websites, ticket platforms
(sporter.md, iTicket, 42km.ro, competi.ro), social media posts and chat groups.
Dates change, registration windows close quietly, and events get cancelled without notice.
RunBaza puts everything in one place on the runner's phone.

## Problem

- There is no single source of truth for running events in the region.
- Registration status (open / closing soon / not yet announced / cancelled) is hard to track.
- Many races take place 15–460 km from Chișinău, and runners without a car struggle to reach them.
- Runners forget registration deadlines and miss early-bird prices.

## Solution — main features

1. **Race index** — a chronological list of all announced races with code, date, name,
   location, distance from Chișinău, available distances (5 / 10 / 21.1 / 42.2 km, …) and
   registration status.
2. **Race details** — start time and gate (meeting point), entry fee and discounts,
   organizer notes, direct link to the registration / ticket page.
3. **Status board** — clear status codes for every event:
   `Boarding` (registration open, buy now), `Last call` (few places left / closing soon),
   `On time` (date confirmed), `TBA` (announced, no registration yet), `Departed` (past),
   `Cancelled`.
4. **Next departure** — a hero card that always shows the nearest upcoming race and a countdown
   in days.
5. **Transfer (carpooling)** — for every out-of-town race: who drives, departure time and
   pick-up point, how many free seats are left, and who is looking for a seat.
6. **Reminders** — local notifications before registration closes and before race day.
7. **Favourites & personal plan** — mark races you plan to run and see your own season plan.
8. **Search and filters** — by month, distance, city, status and race type (road / trail).
9. **Light and dark theme** following iOS system settings.

## Planned screens

| Screen | Purpose |
|---|---|
| Home / Board | Next departure card, key stats (races, open slots, longest distance, days to next start) |
| Race Index | Scrollable list of all races, grouped by season, with filters |
| Race Details | Full information about one race and the registration button |
| Transfer | Carpool offers and seat requests for a selected race |
| My Plan | Favourite races and personal reminders |
| Settings | Theme, notification preferences, home city |

## Technology stack

- **Flutter** (Dart) — cross-platform UI framework, primary target **iOS**
- **Xcode / iOS Simulator** — build and run on macOS
- State management: Provider / Riverpod (to be decided during development)
- Local storage: `shared_preferences` / `sqflite` for favourites and cached race data
- Data source: JSON (local at first, remote endpoint later)
- Notifications: `flutter_local_notifications`
- Version control: Git / GitHub

## Origin

The idea is based on an existing static web prototype — a "departures board" style race index
for the Chișinău running community. This project re-implements the concept as a native-feeling
mobile application with offline access, notifications and interactive carpooling.

## Roadmap

- [x] Choose topic, describe the idea (this README)
- [ ] Set up Flutter project and iOS build
- [ ] UI: Home board and Race Index screens
- [ ] Race Details and Transfer screens
- [ ] Local data layer and favourites
- [ ] Notifications and reminders
- [ ] Testing, polishing, final presentation
