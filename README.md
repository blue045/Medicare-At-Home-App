# Medicare At Home Flutter App

This is a **native Flutter mobile app** for the existing Medicare At Home backend. It is not a WebView wrapper.

The app talks to your current Cloudflare Pages Functions APIs:

- `/api/settings`
- `/api/doctors`
- `/api/blood`
- `/api/ambulance`
- `/api/about`
- `/api/store/products`
- `/api/store/auth/login`
- `/api/store/auth/signup`
- `/api/store/auth/me`
- `/api/store/cart`
- `/api/store/orders`
- `/api/store/payment-settings`

Your existing Cloudflare/Turso backend can stay the same.

## What is included

Native Flutter screens:

- Home page
- Store/product list
- Product detail with image gallery
- Login and signup
- Cart and profile/orders page
- Checkout/order placement
- Doctors list and doctor detail sheet
- Blood donor list, search, sort, detail, and add profile form
- Ambulance request form
- About/team/posts page
- Contact/more menu
- Admin panel link opens your existing web admin page, because admin dashboards are better kept on web

## Important

This project was generated in an environment that does not have the Flutter SDK installed, so I could not run `flutter pub get`, `flutter analyze`, or build an APK here.

After downloading, run the commands below on your own PC or Android Studio setup.

## Setup

### 1. Install Flutter

Install Flutter SDK and Android Studio first.

Check installation:

```bash
flutter doctor
```

### 2. Generate Android/iOS platform folders

This zip contains the Flutter source code. To generate the native platform folders, run this inside the project folder:

```bash
flutter create . --platforms=android,ios --org com.medicareathome
```

For Android only:

```bash
flutter create . --platforms=android --org com.medicareathome
```

### 3. Install packages

```bash
flutter pub get
```

### 4. Connect the app to your deployed website/backend

Run the app with your Cloudflare Pages domain:

```bash
flutter run --dart-define=API_BASE_URL=https://your-site.pages.dev
```

Example:

```bash
flutter run --dart-define=API_BASE_URL=https://medicare-at-home.pages.dev
```

For release APK:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://your-site.pages.dev
```

For app bundle:

```bash
flutter build appbundle --release --dart-define=API_BASE_URL=https://your-site.pages.dev
```

## Android permissions

Because the app uses phone call, WhatsApp/browser links, and internet, make sure Android has internet permission.

After running `flutter create`, open:

```text
android/app/src/main/AndroidManifest.xml
```

Add this above the `<application>` tag if it is not already there:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## Backend requirements

Your existing website backend must be deployed and working first.

Required Cloudflare Pages environment variables are still the same as your web project, including your Turso database variables and store database variables.

The Flutter app does not directly connect to Turso. It only calls your Cloudflare API endpoints.

## Google login note

Email/phone password login and signup are implemented natively.

Google login is not included as a native flow yet. Your current Google login uses browser redirects. To make Google login fully native, you need deep links/custom URL scheme support and a small backend callback change.

## Admin panel note

The admin panel is not rebuilt as native Flutter. The app opens `/su` in the browser. That is intentional because admin panels are easier to maintain on the web and safer to update quickly.

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
    store_screen.dart
    checkout_screen.dart
    auth_screen.dart
    profile_screen.dart
    doctors_screen.dart
    blood_screen.dart
    ambulance_screen.dart
    about_screen.dart
    more_screen.dart
  widgets/
    common.dart
```

## Next improvements

Good next steps:

1. Add native Google login with deep links.
2. Add prescription image upload with `image_picker`.
3. Add push notifications using Firebase Cloud Messaging.
4. Add native admin screens if you really want admin inside the app.
5. Add app icon and splash screen.

## GitHub Actions Android Build Fix

This project contains Dart/Flutter source code only. GitHub must generate the missing Android Gradle scaffold before building the APK.

The included workflow does this automatically:

```bash
flutter create --platforms=android --project-name medicare_at_home_flutter --org com.medicareathome .
flutter pub get
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter build apk --release
```

Workflow file:

```text
.github/workflows/build-android.yml
```

After GitHub Actions finishes, download the APK from the workflow Artifacts section.
