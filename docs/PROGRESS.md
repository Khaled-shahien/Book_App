# Progress

Last updated: 2026-11-04 · branch `production-readiness`

- [x] Phase 1: Audit (`AUDIT.md`)
- [x] Phase 2: Critical fixes and security hardening
- [x] Phase 3: Architecture alignment (partial: the Account page has no controller)
- [~] Phase 4: Performance. Code optimizations done; profiling not done (no device).
- [~] Phase 5: UI/UX. States, forms and undo done; theme tokens, dark mode, l10n/RTL and offline banner open.
- [~] Phase 6: Tests and CI. 37 tests and CI done; golden, integration and auth-controller tests open.
- [x] Phase 7: Docs, checklist and human actions

## Next tasks (in order)
1. `AccountController` + error state; tests with `firebase_auth_mocks`.
2. Theme tokens (`ThemeExtension`) → remove hardcoded colors → re-enable dark mode.
3. `flutter_localizations` + ARB files (languages to be decided) + RTL pass.
4. `connectivity_plus` offline banner + auto-retry.
5. Golden tests for `ErrorStateView` and the cards; `integration_test` for login → home → cart.
6. Crashlytics + Remote Config (force update), after the human console setup.
7. Firebase major-version upgrades, one at a time.
