# Final report: production-readiness pass

Branch: `production-readiness` (base `bb1468d`). 11 commits; 80 files changed.

## What was fixed

**Correctness**
- Category screens no longer overwrite the Home tab's books.
- Out-of-order (stale) search results are discarded.
- Error states with Retry on Home and Category; pull-to-refresh on Home.
- Signed-in users skip Welcome at launch.
- Passwords are no longer trimmed.
- Every Firebase Auth error code maps to a clear message.
- Fixed a crash from `setState` after dispose (details "Undo") and the use of a dialog context after it was popped.
- The cart is cleared on logout, so it no longer leaks to the next user.
- Money uses integer cents.
- Unique Hero tags.
- Firebase init failure no longer kills startup; global error handlers are installed.
- Forgot password works.
- Register writes the Auth-normalized email.
- Account deletion cannot leave a half-deleted account.

**Security**
- Owner-only Firestore rules with schema validation and server-owned counters.
- Release signing via `key.properties`, R8 and resource shrinking, obfuscation in CI.
- Cleartext disabled; system CAs only; cloud backup disabled.
- No logging in release builds.
- Error messages no longer reveal which accounts exist; stronger sign-up passwords.
- No hardcoded config: base URL and key come from `--dart-define-from-file`.
- iOS privacy manifest added.

**Performance**
- Network images decode at display size (`cacheWidth`).
- About 10 MB of unused bundled assets removed.
- Bounded LRU cache; superseded requests are cancelled.
- Retry with backoff only for transient failures.

**UX**
- Undo for cart remove and clear.
- Keyboard actions and autofill hints on forms.
- Search submits from the keyboard.
- Chips stay visible in every state.
- In-app account deletion.
- No dead buttons.

**Quality**
- Strict analysis (`strict-casts`, `strict-inference`, `strict-raw-types`, plus extra lints): **0 issues**.
- Tests went from 1 smoke test to **37 tests**.
- CI enforces format, analyze (fatal infos), tests, AAB and iOS builds on every PR.

## Metrics

| Metric | Before | After |
|---|---|---|
| Analyzer issues (stricter rules after) | 5 | 0 |
| Tests | 1 | 37 (all passing) |
| Coverage, domain + state (services, model, validators, cart, BookController, splash) | n/a | 88.8% |
| Coverage, whole app | n/a | 32.1% |
| Bundled assets | ~14.3 MB | ~4.3 MB (images still used) |
| Release AAB, arm64, R8 + obfuscation | not built (debug-signed APK) | 23.5 MB ✅ built locally |

Cold start, frame times and memory were **not profiled**: there was no device or emulator session. Run `flutter run --profile` with DevTools on a mid-range Android device to record them.

## Production readiness checklist

| Item | State |
|---|---|
| Analyzer clean with strict rules | ✅ |
| Tests pass; domain/state coverage ≥ 80% | ✅ |
| Auth controllers unit-tested (needs `firebase_auth_mocks`) | ⚠️ |
| Golden and integration tests | ❌ follow-up |
| CI pipeline | ✅ (Android job needs the secret) |
| Firestore rules written | ✅ — deployed / emulator-tested: ❌ human |
| Env configuration (dev/staging/prod) | ✅ dart-define files |
| Network hardening (timeouts, retry, typed errors, HTTPS) | ✅ |
| Secure storage for sensitive data | ✅ N/A (no app-held tokens) |
| Android release hardening (R8, signing config, cleartext off, backups off) | ✅ |
| Release keystore / Play App Signing | ❌ human |
| Real application / bundle IDs | ❌ human |
| iOS privacy manifest | ⚠️ file added; add it to the target in Xcode |
| Account deletion in-app | ✅ |
| Crash reporting | ⚠️ hook ready; Crashlytics not added |
| Analytics with consent | ❌ follow-up |
| App Check | ❌ human |
| Complete loading/empty/error states | ✅ Home and Category; ⚠️ Account error state |
| Offline banner / auto-retry | ❌ follow-up (needs `connectivity_plus`) |
| Dark mode | ⚠️ disabled until screens use theme tokens |
| Localization / RTL | ❌ follow-up (target languages undecided) |
| Accessibility (semantics, 200% text) | ⚠️ partial (tooltips, labels); not audited on device |
| Launcher icons / native splash | ❌ needs brand assets |
| Force update / maintenance mode | ❌ follow-up (Remote Config) |
| Payments | ❌ out of scope (business decision) |

Definition of Done status: the engineering items that could be finished without a device, console or new dependencies are ✅. Items still open within engineering scope: dark mode and theme tokens, l10n/RTL, golden and integration tests, connectivity, and Crashlytics wiring. These are the next pass.

## Your to-do list (summary of HUMAN_ACTIONS.md)

1. Deploy `firestore.rules` (test on the emulator first).
2. Pick real app IDs and regenerate the Firebase config files.
3. Create the upload keystore and `android/key.properties`.
4. Add `PrivacyInfo.xcprivacy` to the Xcode target and set the signing team.
5. Enable App Check.
6. Privacy policy, Data Safety form and account-deletion URL.
7. Add the `GOOGLE_SERVICES_JSON_B64` CI secret.
8. Decide target languages, payments and catalogue.
