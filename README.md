# Focusly

Pomodoro timer app built with Flutter. No extra packages needed.

## Features
- Splash screen and 3-page onboarding
- Timer with focus, short break and long break modes
- Statistics with weekly/monthly chart, streak and focus by task
- Session history with All / Focus / Breaks filters
- Settings: durations, auto-start, alarm sound, reset statistics

## Folder structure (lib/)
| Path | Purpose |
|---|---|
| main.dart | App entry point |
| constants/colors.dart | App colors |
| models/entry.dart | One session record |
| state/app_state.dart | Shared settings and history (ChangeNotifier) |
| utils/helpers.dart | Formatting helpers, top bar, reset dialog |
| widgets/ring_painter.dart | Circular progress ring |
| screens/ | Splash, Onboarding, Main (tabs), Timer, Stats, History, Settings |

## How to run
```
flutter create .
flutter pub get
flutter run
```
`flutter create .` generates the android folder if it is missing and does not change lib/.

## Build APK
```
flutter build apk --release
```
