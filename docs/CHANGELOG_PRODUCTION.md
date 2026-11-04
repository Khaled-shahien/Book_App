# Production changelog

## Phase 1: Audit
- **Summary:** full read of `lib/`, tests, Android/iOS config and CI. Report in `AUDIT.md`.
- **Verification:** baseline analyze found 5 issues; 1 test passed.

## Phase 2: Critical fixes and security
- **Commits:**
  - `chore: remove unused assets, dead widgets and stray files`
  - `feat(core): typed failures, env config and hardened books API client`
  - `fix(home): isolate category results, drop stale responses, add error state`
  - `fix(cart): integer-cent money, safe undo, decoded-size images`
  - `fix(auth): keep sessions, map all auth errors, clear state on logout`
  - `fix(app): global error handlers, resilient Firebase init, light theme`
  - `security(android): release signing, R8, cleartext off, no backups`
  - `security(backend): owner-only Firestore rules, env templates, iOS privacy manifest`
- **Verification:** `flutter build appbundle --release --obfuscate --split-debug-info` succeeded locally (23.5 MB, debug-signed because no keystore exists).
- **Behavior changes:**
  - Signed-in users skip Welcome.
  - Generic invalid-credentials message.
  - Stronger sign-up password rule.
  - Light theme on dark-mode devices.
  - Share button removed.
  - Initials avatar.
  - Undo on cart actions.
  - Delete Account tile.
  - Settings tiles say "Coming soon".
  - Forgot password sends an email.
- **Risks:** the rules are not deployed. If production currently relies on open rules, other clients may break: test on the emulator first.

## Phase 3: Architecture
- **Summary:**
  - Constructor injection for services and controllers.
  - Typed `Failure` model.
  - Home controller registered through its route binding.
  - Per-page category controllers.
  - Stricter `analysis_options.yaml`, with every issue fixed.
- **Commit:** `ci: enforce format/analyze/tests; build AAB and iOS on every PR` (includes the lint changes).
- **Follow-up:** the Account page still calls Firestore directly; move it to an `AccountController`.

## Phase 4: Performance
- **Summary:** `cacheWidth` on covers, ~10 MB of assets removed, bounded cache, request cancellation, no full-page spinner on chip taps.
- **Not done:** profile-mode baselines. No device was available.

## Phase 5: UI/UX
- **Summary:** reusable `ErrorStateView`, pull-to-refresh, form autofill and keyboard actions, Undo.
- **Screens changed:**
  - Home: chips always visible; error and retry.
  - Category: error and retry.
  - Cart: undo.
  - Details: no Share button.
  - Account: initials avatar and Delete Account.
  - Login: forgot password.
- **Not done:** theme tokens, dark mode, l10n/RTL, offline banner.

## Phase 6: Testing and CI
- **Commit:** `fix(auth): address independent review findings; add Home state tests`
- **Verification:** 37 tests pass. Domain/state coverage is 88.8%.
- **Self-review:** an independent sub-agent reviewed the diff and found 4 defects (email case vs. the rule, deletion ordering, tag collision, sign-out order). All are fixed.

## Phase 7: Readiness
- **Summary:** docs (`DECISIONS.md`, `HUMAN_ACTIONS.md`, `FINAL_REPORT.md`) and the README update.
