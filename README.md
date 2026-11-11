# Firebase Auth Lab — In-Class Activity 13B (CSC 4360)

Flutter app with Firebase Authentication: register, sign in, sign out, profile email display, and password update with reauthentication.

## Features
- **AuthService** (`lib/services/auth_service.dart`) — the only place that calls `FirebaseAuth`: `register`, `signIn`, `signOut`, `updatePassword`, `reauthenticateAndUpdate`, `currentUser`, `authStateChanges`.
- **Auth-state routing** (`lib/screens/auth_gate.dart`) — `StreamBuilder` on `authStateChanges()`; signed-in users see the profile, signed-out users see sign-in. Profile is unreachable while signed out.
- **Sign in / Register** (`lib/screens/authentication_screen.dart`) — email format + 6-char password validation, confirm-password on register, loading spinner, button disabled during requests.
- **Profile** (`lib/screens/profile_screen.dart`) — current email, sign out, change password. On `requires-recent-login`, the dialog asks for the current password, reauthenticates, and retries.
- **Safe errors** — Firebase error codes mapped to friendly messages; raw exceptions never shown. Wrong-password and unknown-user share one message so the app doesn't reveal which emails exist.

## Setup
1. Firebase Console → create a project → **Authentication → Sign-in method → enable Email/Password**.
2. Install CLIs:
   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   firebase login
   ```
3. From the project root:
   ```bash
   flutter pub get
   flutterfire configure   # select your project, include Android
   ```
   This generates `lib/firebase_options.dart` and `android/app/google-services.json`.
4. Confirm `android/app/src/main/AndroidManifest.xml` has, directly inside `<manifest>`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   ```

## Run & test
```bash
flutter run                 # debug on emulator/device
flutter test                # validator unit tests
flutter build apk --release # → build/app/outputs/flutter-apk/app-release.apk
```

Manual test flow: register → profile shows email → sign out → sign in → change password → sign out → old password fails → new password works → close & reopen app (session restored).

## Security notes
- Passwords are handled only by Firebase Auth; nothing is stored in Firestore or locally.
- Never commit signing keys or service-account credentials.
