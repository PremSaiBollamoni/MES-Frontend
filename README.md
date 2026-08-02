# GTMES Frontend

Flutter client for **GTMES** — the GramTarang Garments Manufacturing Execution System. A
role-aware application for the factory floor covering operator allocation, live work tracking,
hourly production entry, biometric attendance, stock and WIP control, and generated reports.

| | |
|---|---|
| **SDK** | Dart `^3.12.1` · Flutter stable |
| **Primary target** | Android (handsets carried on the floor) |
| **Also configured** | iOS, Web, Windows, Linux, macOS |
| **Languages** | English and Telugu, complete parity |
| **Backend** | `https://smobza.thegttech.com` |

---

## Key features

- **Seven role-specific experiences** — navigation, dashboard and permitted screens are all
  derived from the active role. Users holding several roles switch without logging out.
- **Operator allocation and live tracking** — assign operators to stations, run a work timer,
  and watch efficiency recalculate against the station's standard time.
- **Hourly production entry** — the shift split into eight one-hour slots with running day
  totals; multiple entries per hour, with capacity and overlap protection.
- **Biometric attendance** — live, daily and monthly views; only employees confirmed present
  can be allocated or logged against.
- **Stock and WIP** — per-station availability, daily zone balances, and bundle tracking.
- **Reports** — four report types generated on the server and opened as PDFs on the device.
- **Full Telugu localisation** — screens, messages, all 39 operation names, and employee names.

---

## Tech stack

| Concern | Package |
|---|---|
| HTTP | `http` ^1.6.0 |
| Local persistence | `shared_preferences` ^2.5.5 |
| Localisation | `flutter_localizations`, `intl` |
| Typography | `google_fonts` ^6.2.1 |
| PDF viewing | `printing` ^5.13.4 |
| Image capture | `image_picker` ^1.1.2 |
| Lints | `flutter_lints` ^6.0.0 |
| Launcher icons | `flutter_launcher_icons` ^0.14.4 |

---

## Folder structure

```
lib/
├── main.dart              MaterialApp, locale wiring, theme
├── activities/            screens, one file per screen
│   ├── operations/        allocation, tracking, production entry, stock, WIP
│   └── reports/           report list, type screen, PDF opener
├── components/            reusable widgets
│   └── dashboard/         the four role dashboards
├── models/                request/response models with JSON mapping
├── services/              one API service per backend domain + client and session
├── utils/                 config, theme tokens, locale controller, name lookups
└── l10n/                  app_en.arb, app_te.arb, generated localisations
```

`l10n.yaml` drives generation: template `lib/l10n/app_en.arb`, output class `L10n`.

---

## Prerequisites

- **Flutter SDK** on a stable channel with Dart `^3.12.1`
- **Android Studio** or the Android SDK with a device or emulator
- A reachable **GTMES backend** — see [`../backend/README.md`](../backend/README.md)

## Installation

```bash
git clone <repository-url>
cd frontend
flutter pub get
```

## Environment variables

This project has none. The single environment-specific value is the backend URL, compiled in
from `lib/utils/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = "https://smobza.thegttech.com";
}
```

The file holds commented alternatives for local work. Uncomment exactly one:

| Target | Value | Notes |
|---|---|---|
| Production | `https://smobza.thegttech.com` | No `/smo` suffix — nginx already maps the domain root onto that context |
| USB tunnel | `http://localhost:8080` | Requires `adb reverse tcp:8080 tcp:8080`; survives neither unplugging nor reboot |
| Wi-Fi | `http://<pc-lan-ip>:8080` | Same network, plus inbound 8080 allowed through the firewall |

> Restore the production URL before building a release APK.

---

## Running

```bash
flutter devices                    # list connected devices
flutter run                        # debug build on the default device
flutter run -d <device-id>         # target a specific device
```

Testing against a locally running backend over USB:

```bash
adb reverse tcp:8080 tcp:8080      # re-run after any unplug or reboot
```

## Building for production

```bash
flutter build apk --release        # → build/app/outputs/flutter-apk/app-release.apk
flutter build appbundle --release  # Play Store bundle
```

Confirm before shipping: `api_config.dart` points at production, and the app label in
`android/app/src/main/AndroidManifest.xml` reads `GTMES`.

## Available commands

| Command | Purpose |
|---|---|
| `flutter pub get` | Install dependencies |
| `flutter analyze` | Static analysis — must be free of errors |
| `flutter test` | Run tests |
| `flutter gen-l10n` | Regenerate localisations after editing an `.arb` |
| `dart run flutter_launcher_icons` | Regenerate launcher icons from `assets/icon/app_icon.png` |
| `flutter clean` | Clear build artefacts |

---

## Architecture

Screens are `StatefulWidget`s that call a service, hold the result in local state, and render
it. Services own all network access; widgets never call `http` directly.

```
Screen  →  <Domain>ApiService  →  ApiClient  →  backend
                                     │
                                     └─ AuthSession (bearer token)
```

**Nothing is calculated on the device.** Efficiency, wages, standard minutes and classification
all arrive from the server, so no device can display a figure that disagrees with another.

### State management

No third-party state library. Three mechanisms cover the application:

- **`setState`** for screen-local state — the default.
- **`AuthSession`** — a singleton holding the bearer token and current user, persisted to
  `shared_preferences` so a session survives an app restart.
- **`LocaleController`** — a singleton `ValueNotifier<Locale>`. `main.dart` rebuilds only
  `MaterialApp` on change, so a language switch reaches every screen without a restart.

### API integration and caching

`ApiClient` provides a process-wide GET cache keyed by full URL, with a 15-minute default TTL.
Screens were otherwise re-fetching reference data — and re-triggering biometric syncs — on every
visit. Pass `forceRefresh: true` to bypass it; call the cache-clear helper after any mutation
whose result other screens' cached reads would contradict.

Error responses carrying an `ErrorCodes` value are mapped to localised text by
`utils/error_messages.dart`, so server English is never shown to the user.

### Routing

Navigation is imperative — `Navigator.push` with `MaterialPageRoute`; there is no route table.
`main.dart` sets `home: SplashScreen()`, which restores any saved session and continues to the
login screen or straight to `MainShellScreen`. The shell hosts the drawer and swaps the body
per selected destination; destinations are filtered by the active role's activities.

### Screens

The full inventory, grouped by area and annotated with the activity that gates each one, is in
**[docs/SCREENS.md](docs/SCREENS.md)**.

### Theming

`utils/theme_tokens.dart` centralises colour, typography, spacing and radii. Use the tokens
rather than literal values so the interface stays consistent.

---

## Deployment

The client ships as an APK installed on floor handsets; there is no app-store channel.

1. Confirm `api_config.dart` targets production.
2. `flutter build apk --release`
3. Distribute `build/app/outputs/flutter-apk/app-release.apk` and install on each device.

Because updates are manual, roll a release out to all supervisor handsets together — a device
left on an older build keeps posting under the old contract.

---

## Troubleshooting

| Symptom | Cause and fix |
|---|---|
| Release APK has no network, debug is fine | `INTERNET` permission missing from `android/app/src/main/AndroidManifest.xml`. Debug and profile manifests get it automatically; release does not. |
| `No route to host` from a device | Phone cannot reach the PC. Use `adb reverse tcp:8080 tcp:8080` with `baseUrl` set to `localhost`. |
| Data looks stale | The 15-minute GET cache. Pull to refresh, or pass `forceRefresh: true`. |
| Timer starts at a wrong value | A timestamp parsed without a timezone marker is treated as local. Server times are UTC. |
| Telugu text missing on a screen | An interpolated string not yet extracted to `.arb`. Add the key and run `flutter gen-l10n`. |
| Build fails after editing an `.arb` | Run `flutter gen-l10n`; check both `app_en.arb` and `app_te.arb` carry the key. |
| `RenderFlex overflowed` | Fixed-width layout on a narrow device. Use `Wrap`, `Flexible` or `Expanded`. |

---

## Contributing

- **Keep files small and single-purpose.** Split a screen into components before it grows
  large, rather than refactoring afterwards.
- **A new screen needs a new activity** — added to the backend catalogue, granted to roles in a
  migration, and enforced by the navigation guard in the same change. Never ship an ungated
  screen.
- **Build responsively.** Derive layout from `MediaQuery.of(context).size.width`; never hardcode
  column counts or sizes. Breakpoints: mobile < 600, tablet 600–1024, web > 1024.
- **No user-facing string literals.** Add the key to `app_en.arb` and `app_te.arb`, then run
  `flutter gen-l10n`.
- **Use `ThemeTokens`,** not literal colours or sizes.
- **Widgets never call `http` directly** — go through a service.
- `flutter analyze` must report no errors before a pull request.
