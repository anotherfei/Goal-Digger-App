# Firebase Emulator vs Real Firebase Setup

This project now uses **one codebase** with different environment configuration.
The Flutter app logic is the same for development and production.
Only the Firebase target changes.

## Development / debugging mode

Start the Firebase Emulator Suite first:

```powershell
firebase.cmd emulators:start --only auth,firestore,functions
```

Open the emulator UI:

```text
http://localhost:4000/
```

Then run Flutter:

```powershell
flutter clean
cd android
.\gradlew.bat clean
cd ..
flutter pub get
adb uninstall com.example.fltr_test
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
```

Expected Flutter log:

```text
✅ Firebase Core initialized
🧪 Connected to Firebase emulators at 10.0.2.2
🧪 Emulator UI: http://localhost:4000
```

Guest sign-in should create a user under the **Authentication** tab of the emulator UI.

## Real Firebase mode

Use this only when you want to test against the real Firebase project:

```powershell
flutter clean
flutter pub get
adb uninstall com.example.fltr_test
flutter run --dart-define=USE_REAL_FIREBASE=true
```

Release builds should also use real Firebase:

```powershell
flutter build apk --release --dart-define=USE_REAL_FIREBASE=true
```

## What changed

### Android debug/profile only

These files allow local emulator HTTP traffic to `10.0.2.2`:

```text
android/app/src/debug/AndroidManifest.xml
android/app/src/debug/res/xml/debug_network_security_config.xml
android/app/src/profile/AndroidManifest.xml
android/app/src/profile/res/xml/profile_network_security_config.xml
```

This fixes:

```text
Cleartext HTTP traffic to 10.0.2.2 not permitted
```

### Android release

This file explicitly disables cleartext in release builds:

```text
android/app/src/release/AndroidManifest.xml
```

### Firebase initializer

`lib/firebase/firebase_initializer.dart` keeps App Check disabled when using local emulators. App Check should only activate in release/real Firebase mode, otherwise local Auth can fail before the emulator receives the request.

## Common mistake

If you still see this error:

```text
Cleartext HTTP traffic to 10.0.2.2 not permitted
```

then you are probably still running an old extracted folder. Confirm these files exist in your current project:

```text
android/app/src/debug/AndroidManifest.xml
android/app/src/debug/res/xml/debug_network_security_config.xml
```

Then run:

```powershell
flutter clean
cd android
.\gradlew.bat clean
cd ..
adb uninstall com.example.fltr_test
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
```
