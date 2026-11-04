# Human actions required

These steps need console access, keys or business decisions. Everything that could be done in code is already done.

No secrets were found committed to git (`google-services.json` exists locally but is git-ignored), so **no credential rotation is needed**.

## Before the first store release (blocking)

1. **Deploy the Firestore rules.** Review `firestore.rules`, then test them on the emulator: `firebase emulators:start --only firestore`. Deploy with `firebase deploy --only firestore:rules`. Confirm that the production project is not in test mode.
2. **Choose real app IDs** to replace `com.example.book_app` and `com.example.bookApp`. Register them in Firebase, download new `google-services.json` and `GoogleService-Info.plist`, and update `applicationId` in `android/app/build.gradle.kts` and the bundle ID in Xcode. (D-013)
3. **Create the Android upload key:**
   `keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
   Then copy `android/key.properties.example` to `android/key.properties` and fill it in. Enroll in Play App Signing. Never commit the key or the properties file.
4. **iOS:** open `ios/Runner.xcworkspace`, set your Team, and add `Runner/PrivacyInfo.xcprivacy` to the Runner target (drag it in, tick "Runner"). Make sure the App Store privacy answers match it.
5. **Enable Firebase App Check** (Play Integrity / App Attest) for Firestore and Auth, then add the `firebase_app_check` dependency (a small code change).
6. **Store listings:** host a privacy policy URL; fill in the Google Play Data Safety form (email and name collected for app functionality, data deletable in-app); provide the account-deletion URL and the in-app path (Account → Delete Account).
7. **Launcher icons and splash:** provide brand artwork. `flutter_launcher_icons` and `flutter_native_splash` can generate them once you have assets.

## CI

8. Add a repository secret `GOOGLE_SERVICES_JSON_B64` (`base64 -w0 android/app/google-services.json`). Until it exists, the Android build job is skipped with a warning.
9. Optional: add `CODECOV_TOKEN`.

## Recommended

10. **Crashlytics:** add `firebase_crashlytics`, then in `main()` set
    `AppLogger.errorReporter = (e, s, {fatal = false}) => FirebaseCrashlytics.instance.recordError(e, s, fatal: fatal);`
    and upload the `build/symbols` produced by `--split-debug-info`.
11. Restrict the Google Books API key, if you add one (`BOOKS_API_KEY`), to your package and bundle IDs in Google Cloud.
12. Add a Cloud Function on Auth user deletion that removes `users/{uid}` as a backstop (D-008), and functions that maintain the order/favorite/review counters.
13. Decide on payments and the product catalogue (see the gap analysis in DECISIONS.md).
14. Choose the target languages so localization and RTL can be implemented.
