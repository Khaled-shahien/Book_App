# Firebase Migration Checklist

This checklist will guide you through migrating the Flutter project from the previous owner's Firebase project to your personal Firebase project.

## Current State
- Project Name: book_app
- Current Firebase Project: book-app-d06bf
- Android Package ID: com.example.book_app
- iOS Bundle ID: com.example.bookApp

## Step 1: Install Required Tools

If you don't have the tools installed, run these commands:

```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
```

## Step 2: Configure FlutterFire

From the project root directory, run:

```bash
flutterfire configure
```

When prompted:
1. Select your Firebase project from the list (or create a new one)
2. Select platforms: Android and iOS
3. For Android, ensure the package name stays as: `com.example.book_app`
4. For iOS, the tool will detect the bundle ID from `ios/Runner/Info.plist`

## Step 3: Verify Configuration Files

After running `flutterfire configure`, these files will be generated/updated:
- `lib/firebase_options.dart` - Contains platform-specific Firebase configuration
- `android/app/google-services.json` - Android Firebase configuration
- `ios/Runner/GoogleService-Info.plist` - iOS Firebase configuration

## Step 4: Update Android Configuration

Verify that `android/app/build.gradle.kts` contains:
```kotlin
plugins {
    id("com.google.gms.google-services") // Make sure this line exists
}
```

## Step 5: Update iOS Configuration (Mac Required)

1. Navigate to the iOS directory:
```bash
cd ios
pod install
cd ..
```

2. Ensure the `GoogleService-Info.plist` file is in the correct location:
`ios/Runner/GoogleService-Info.plist`

## Step 6: Clean and Rebuild

Run these commands to ensure everything works properly:

```bash
flutter clean
flutter pub get
flutter run
```

## Important Notes

- The application ID (`com.example.book_app`) will remain unchanged
- The Firebase initialization is handled safely through the `FirebaseInit` class to prevent duplicate initialization errors
- If you encounter any build issues, ensure your `firebase.json` file reflects the correct project configuration after running `flutterfire configure`