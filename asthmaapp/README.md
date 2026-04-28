# asthmaapp

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase Hosting build key setup

When deploying web to Firebase Hosting, the AirNow key must be available at
build time.

From the `asthmaapp` folder:

### PowerShell (Windows)

```powershell
$env:AIRNOW_API_KEY = "your_airnow_api_key"
flutter pub get
flutter build web --dart-define=AIRNOW_API_KEY=$env:AIRNOW_API_KEY
cd ..
firebase deploy --only hosting
```

### Bash (macOS/Linux)

```bash
export AIRNOW_API_KEY="your_airnow_api_key"
flutter pub get
flutter build web --dart-define=AIRNOW_API_KEY="$AIRNOW_API_KEY"
cd ..
firebase deploy --only hosting
```

If you skip `--dart-define`, the hosted app will show an API key configuration error.
