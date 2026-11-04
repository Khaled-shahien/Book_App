# Decisions log

Decisions made on the owner's behalf during the production-readiness pass. Each one is reversible unless noted.

| ID | Decision | Alternatives | Reason |
|---|---|---|---|
| D-001 | Keep GetX for state, DI and routing | Riverpod, BLoC, go_router | AGENTS.md requires respecting the stack; GetX is maintained; a migration would be all risk and no user value right now. |
| D-002 | Target architecture: GetX controller → service with constructor injection (defaults to the real Firebase/Dio instances) → typed `Failure` | Clean architecture with use-cases; get_it | It is the smallest change that makes controllers unit-testable with fakes and needs no new dependencies. |
| D-003 | Typed `sealed class Failure` that the service throws, instead of a `Result<T>` wrapper | `Result`/`Either` | It fits the existing `try/catch` controller code with the least churn and is still exhaustive. |
| D-004 | Money in integer cents. The flat demo price stays at $9.99 (`kPlaceholderPriceCents`) | Real prices | Changing pricing is a business decision. Google Books has no reliable sale price. Before any checkout, the price must come from a server. |
| D-005 | Force `ThemeMode.light` | Keep system mode; full dark-mode pass | Screens hardcode light colors, and system dark mode produced white-on-white text. Light-only removes the bug now. The dark theme stays defined for the tokenization follow-up. **User-visible:** dark-mode devices now see the light UI (previously broken). |
| D-006 | Do not jump Firebase majors (core 4→5, auth 6→7, firestore 6→7) or google_fonts 6→9 in this pass | Upgrade now | Each is a major version with migration notes. They should be done one at a time with device testing, and the current versions have no known vulnerabilities. Listed in follow-ups. |
| D-007 | Keep google_fonts runtime fetching (Inter) | Bundle Inter as an asset; system font | Keeps the brand look. Recommendation: bundle the font and set `GoogleFonts.config.allowRuntimeFetching = false` for offline use and privacy. |
| D-008 | Account deletion deletes the profile, then the Auth user, after checking that the sign-in is recent (5 min) | Re-auth dialog; Cloud Function | It needs no backend work. Recommended backstop: a Cloud Function on `auth.user().onDelete` that deletes `users/{uid}`. |
| D-009 | Sign-up password policy: 8–128 characters, letters + digits. Sign-in only checks presence | Keep the 6-character minimum | OWASP/NIST guidance. Existing 6-character accounts can still sign in. **User-visible.** |
| D-010 | One generic "Incorrect email or password", and a generic password-reset confirmation | Specific messages | Prevents account enumeration. **User-visible.** |
| D-011 | Remove the no-op Share button; settings tiles show "Coming soon"; add a Delete Account tile | Leave as is | Dead controls hurt trust; deletion is required by the stores. **User-visible.** |
| D-012 | Replace the hotlinked flaticon avatar with an initials avatar | Keep it | Third-party hotlinking leaks IP/usage, and the image can disappear. **User-visible.** |
| D-013 | Do not change `applicationId` / bundle ID (`com.example.*`) | Rename | It must match the Firebase app registration (`google-services.json`); renaming needs console access. Human action. |
| D-014 | Flavors via `--dart-define-from-file` (`env/*.example.json`) instead of Gradle/Xcode flavors | Native flavors | The app has no per-env native config besides Firebase files. This is simpler and works on all platforms. Native flavors are needed only once separate Firebase projects exist. |
| D-015 | No certificate pinning | Pin Google APIs | Google rotates certificates; pinning a public, keyless API adds outage risk for little gain. |
| D-016 | No new test dependencies (hand-written fakes instead of mocktail/firebase mocks) | mocktail, firebase_auth_mocks | AGENTS.md restricts pubspec changes. Fakes cover the domain layer. Auth controllers need `firebase_auth_mocks` to reach coverage targets (follow-up). |
| D-017 | CI targets the **stable** channel. The local machine uses beta 3.48 | Pin a version | Stable is what ships. Pin `flutter-version` once a release version is chosen. |

## Gap analysis (product level, nothing implemented)

- **Payments/checkout:** none exists ("coming soon"). Options: (a) Stripe via a backend (Cloud Functions) for physical books; (b) for digital goods on iOS/Android, store IAP is mandatory. **Recommendation:** decide what is sold first. Prices must come from the server; never trust the client total.
- **Real catalogue vs. Google Books demo data:** fine for discovery. Selling needs your own catalogue (a Firestore `books` collection + admin tooling).
- **Orders/favorites/reviews counters:** shown but never incremented. They must be maintained server-side; the rules block client edits.
- **Force update / maintenance mode:** recommend Firebase Remote Config (`min_supported_version`, `maintenance`) checked at splash. This needs the `firebase_remote_config` dependency plus console setup, so it is not implemented.
