# Medicare At Home Android App

This Flutter project is the Android app version of the public Medicare At Home website.

It keeps the public customer side of the website inside the app and connects to your existing Cloudflare Pages Functions backend:

- Home
- Services
- Store and product details
- Login and signup
- Cart, profile, and orders
- Doctors list and doctor details
- Blood section with search, sorting, detail view, and add form
- Ambulance request form
- Contact page
- About/team/posts page

The app uses your live website/API URL:

```text
https://medicareathome.pages.dev
```

## Build with GitHub Actions

The workflow is already included here:

```text
.github/workflows/build-android.yml
```

Push this project to GitHub, then open:

```text
GitHub repo → Actions → Build Flutter Android App → Run workflow
```

After the workflow finishes, download the APK from the Artifacts section.

## Local Android build

Install Flutter and Android Studio first, then run:

```bash
flutter create --platforms=android --project-name medicare_at_home_flutter --org com.medicareathome .
rm -rf test
flutter pub get
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter build apk --release --dart-define=API_BASE_URL=https://medicareathome.pages.dev
```

APK output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## API URL

The GitHub workflow sets:

```yaml
env:
  API_BASE_URL: https://medicareathome.pages.dev
```

Change this only if your Cloudflare Pages URL changes.

## Android permission

The workflow automatically adds Android internet permission before building:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## Folder structure

```text
lib/
  core/
    api_client.dart
    app_config.dart
    app_state.dart
    app_theme.dart
  models/
    models.dart
  screens/
    home_screen.dart
    services_screen.dart
    store_screen.dart
    checkout_screen.dart
    auth_screen.dart
    profile_screen.dart
    doctors_screen.dart
    blood_screen.dart
    ambulance_screen.dart
    contact_screen.dart
    about_screen.dart
    more_screen.dart
  widgets/
    common.dart
```
