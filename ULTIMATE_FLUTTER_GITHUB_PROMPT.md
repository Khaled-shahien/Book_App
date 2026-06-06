# Ultimate Flutter GitHub Repository Optimization Prompt
# For: OpenAI Codex Agent
# Works with: Any Flutter Project
# ============================================================

You are a Senior Flutter Developer, GitHub Expert, and DevOps Engineer.
Your mission is to transform this Flutter repository into a world-class,
professional, production-ready open-source project.

Read the entire prompt carefully before executing anything.
Execute ALL tasks in order. Do not skip any task.
After completing everything, open a single Pull Request with all changes.

---

## ═══════════════════════════════════════
## PHASE 1 — SECURITY & CLEANUP (CRITICAL)
## ═══════════════════════════════════════

### 1.1 — Scan and Remove Dangerous Files

Search the entire repository (including root, subdirectories, and all branches)
for the following files and DELETE them immediately if found:

- Any file whose name looks like a mistyped git command
  (e.g. files named "et --hard abc1234", "eset --hard", "it reset", etc.)
- *.excalidraw files (design scratch files)
- *.figma, *.sketch files
- Loose *.scss or *.less files in the root that are not part of the Flutter project
- Loose data files in root: data.json, test.json, dummy.json, mock.json
- *.bak, *.tmp, *.log files
- Any file named "Untitled*" or "Copy of*"
- pubspec.lock (should not be version-controlled in app projects)

### 1.2 — Audit for Exposed Secrets

Scan every file in the repository for hardcoded secrets.
Look for patterns like:
- API keys: strings matching `AIza...`, `sk-...`, `Bearer ...`
- Firebase config values hardcoded in Dart files
- Passwords or tokens in any config file

If any are found:
1. Remove them immediately from the file
2. Replace with: `const String apiKey = String.fromEnvironment('API_KEY');`
3. Document each finding in the PR description under "⚠️ Security Fixes"

### 1.3 — Create Comprehensive .gitignore

Replace or create .gitignore in the root with the following content exactly:

```
# ── Flutter & Dart ──────────────────────────────────
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
*.dart_snapshot
pubspec.lock

# Generated code
*.g.dart
*.freezed.dart
*.gr.dart
*.mocks.dart

# ── Firebase (NEVER COMMIT) ──────────────────────────
google-services.json
GoogleService-Info.plist
firebase_options.dart
firebase.json
.firebaserc
**/google-services.json
**/GoogleService-Info.plist

# ── Environment & Secrets (NEVER COMMIT) ────────────
.env
.env.local
.env.staging
.env.production
.env.*
*.env
secrets.dart
secrets.json

# ── Android ──────────────────────────────────────────
**/android/**/gradle-wrapper.jar
**/android/.gradle
**/android/captures/
**/android/gradlew
**/android/gradlew.bat
**/android/local.properties
**/android/**/GeneratedPluginRegistrant.java
**/android/key.properties
**/*.keystore
**/*.jks

# ── iOS ───────────────────────────────────────────────
**/ios/**/*.mode1v3
**/ios/**/*.mode2v3
**/ios/**/*.moved-aside
**/ios/**/*.pbxuser
**/ios/**/*.perspectivev3
**/ios/**xcuserdata
**/ios/.generated/
**/ios/Flutter/App.framework
**/ios/Flutter/Flutter.framework
**/ios/Flutter/Flutter.podspec
**/ios/Flutter/Generated.xcconfig
**/ios/Flutter/ephemeral
**/ios/Flutter/app.flx
**/ios/Flutter/app.zip
**/ios/Flutter/flutter_assets/
**/ios/ServiceDefinitions.json
**/ios/Runner/GeneratedPluginRegistrant.*
Podfile.lock

# ── macOS ─────────────────────────────────────────────
**/macos/Flutter/GeneratedPluginRegistrant.swift
**/macos/Flutter/ephemeral

# ── IDE & Editors ─────────────────────────────────────
.idea/
.vscode/
*.iml
*.ipr
*.iws
.DS_Store
.DS_Store?
._*
Thumbs.db
ehthumbs.db

# ── Design & Scratch Files ────────────────────────────
*.excalidraw
*.figma
*.sketch
*.xd

# ── Misc ──────────────────────────────────────────────
*.log
*.tmp
*.bak
*.swp
coverage/
lcov.info
```

---

## ═══════════════════════════════════════
## PHASE 2 — GITHUB ACTIONS CI/CD PIPELINE
## ═══════════════════════════════════════

Create the file `.github/workflows/flutter-ci.yml` with the following content:

```yaml
name: Flutter CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]
  release:
    types: [ published ]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:

  # ────────────────────────────────────────
  # JOB 1: Code Quality & Tests
  # ────────────────────────────────────────
  quality:
    name: 🔍 Analyze & Test
    runs-on: ubuntu-latest
    steps:
      - name: 📥 Checkout
        uses: actions/checkout@v4

      - name: 🐦 Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'
          cache: true

      - name: 📦 Install dependencies
        run: flutter pub get

      - name: 🔍 Dart format check
        run: dart format --output=none --set-exit-if-changed .

      - name: 🧹 Flutter analyze
        run: flutter analyze --no-fatal-infos

      - name: 🧪 Run tests with coverage
        run: flutter test --coverage --reporter=expanded
        continue-on-error: true

      - name: 📊 Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          file: coverage/lcov.info
          fail_ci_if_error: false
        continue-on-error: true

  # ────────────────────────────────────────
  # JOB 2: Build Android APK
  # ────────────────────────────────────────
  build-android:
    name: 🤖 Build Android APK
    runs-on: ubuntu-latest
    needs: quality
    if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/develop'
    steps:
      - name: 📥 Checkout
        uses: actions/checkout@v4

      - name: 🐦 Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'
          cache: true

      - name: ⚙️ Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: 📦 Install dependencies
        run: flutter pub get

      - name: 🔑 Create environment file
        run: |
          touch .env
          echo "# Generated by CI" >> .env
        env:
          GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}

      - name: 🏗️ Build APK (split per ABI)
        run: flutter build apk --release --split-per-abi

      - name: 📤 Upload APK artifact
        uses: actions/upload-artifact@v4
        with:
          name: android-apk-${{ github.sha }}
          path: build/app/outputs/flutter-apk/*.apk
          retention-days: 30

  # ────────────────────────────────────────
  # JOB 3: Build iOS (check only)
  # ────────────────────────────────────────
  build-ios:
    name: 🍎 Build iOS (check)
    runs-on: macos-latest
    needs: quality
    if: github.ref == 'refs/heads/main'
    steps:
      - name: 📥 Checkout
        uses: actions/checkout@v4

      - name: 🐦 Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'
          cache: true

      - name: 📦 Install dependencies
        run: flutter pub get

      - name: 🏗️ Build iOS (no codesign)
        run: flutter build ios --release --no-codesign

  # ────────────────────────────────────────
  # JOB 4: Auto Release on Tag
  # ────────────────────────────────────────
  release:
    name: 🚀 Create Release
    runs-on: ubuntu-latest
    needs: quality
    if: startsWith(github.ref, 'refs/tags/v')
    permissions:
      contents: write
    steps:
      - name: 📥 Checkout
        uses: actions/checkout@v4

      - name: 🐦 Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'

      - name: ⚙️ Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: 📦 Install dependencies
        run: flutter pub get

      - name: 🏗️ Build release APK
        run: flutter build apk --release

      - name: 🚀 Publish GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          files: build/app/outputs/flutter-apk/app-release.apk
          generate_release_notes: true
          name: "Release ${{ github.ref_name }}"
          draft: false
          prerelease: false
```

---

## ═══════════════════════════════════════
## PHASE 3 — GITHUB COMMUNITY FILES
## ═══════════════════════════════════════

### 3.1 — Create AGENTS.md (Codex permanent instructions)

Create `AGENTS.md` in the root:

```markdown
# AGENTS.md

This file provides instructions for AI coding agents (Codex, Jules, etc.).
Read this file completely before starting any task.

## Project
Flutter mobile application using Clean Architecture.
Stack: Flutter, Dart, BLoC/Cubit, get_it, Dio, Firebase, go_router.

## Commands
Always run after any change:
- flutter pub get
- flutter analyze --no-fatal-infos
- flutter test

## Commit Standard (Conventional Commits)
feat(scope): add new feature
fix(scope): fix a bug
chore: maintenance, config
docs: documentation only
refactor(scope): restructure without behavior change
test(scope): add or update tests
style: formatting only

## Branching
- main → stable production code only
- develop → integration branch
- feat/xxx → new feature
- fix/xxx → bug fix
- docs/xxx → documentation

## Security Rules
NEVER commit: google-services.json, GoogleService-Info.plist,
firebase_options.dart, .env, key.properties, *.keystore, *.jks
NEVER hardcode API keys in Dart files.

## Protected
Do NOT modify lib/ source code unless explicitly asked.
Do NOT modify pubspec.yaml unless adding a specific requested dependency.
```

### 3.2 — Create CONTRIBUTING.md

Create `CONTRIBUTING.md` in the root:

```markdown
# Contributing Guide

Thank you for considering contributing to this project!

## Getting Started
1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/REPO_NAME.git`
3. Create a branch: `git checkout -b feat/your-feature`
4. Make your changes following the code standards below
5. Run `flutter analyze` and `flutter test` — both must pass
6. Commit using Conventional Commits format
7. Push and open a Pull Request targeting `develop`

## Code Standards
- Follow Clean Architecture (Presentation / Domain / Data)
- Use BLoC/Cubit for state management
- Handle errors with Either (dartz)
- Write unit tests for all BLoC/Cubit classes
- No hardcoded strings — use constants or localization

## Commit Messages
Format: `type(scope): description`
Types: feat, fix, docs, style, refactor, test, chore

## Pull Request Checklist
- [ ] `flutter analyze` passes with 0 errors
- [ ] `flutter test` passes
- [ ] Code follows Clean Architecture
- [ ] No secrets or API keys committed
- [ ] PR description explains what and why

## Bug Reports
Open an issue with:
- Flutter version (`flutter --version`)
- Device/OS
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable
```

### 3.3 — Create Issue Templates

Create `.github/ISSUE_TEMPLATE/bug_report.md`:

```markdown
---
name: Bug Report
about: Report a bug to help us improve
title: '[BUG] '
labels: bug
assignees: ''
---

## Bug Description
A clear description of what the bug is.

## Steps to Reproduce
1. Go to '...'
2. Tap on '...'
3. See error

## Expected Behavior
What you expected to happen.

## Actual Behavior
What actually happened.

## Environment
- Flutter version:
- Device:
- OS version:
- App version:

## Screenshots
If applicable, add screenshots.
```

Create `.github/ISSUE_TEMPLATE/feature_request.md`:

```markdown
---
name: Feature Request
about: Suggest a new feature or improvement
title: '[FEATURE] '
labels: enhancement
assignees: ''
---

## Feature Description
A clear description of the feature you want.

## Problem it Solves
What problem does this feature solve?

## Proposed Solution
How do you envision this working?

## Alternatives Considered
Any alternative solutions you've thought of.

## Additional Context
Any mockups, examples, or extra context.
```

### 3.4 — Create Pull Request Template

Create `.github/PULL_REQUEST_TEMPLATE.md`:

```markdown
## Summary
Brief description of what this PR does.

## Type of Change
- [ ] feat: New feature
- [ ] fix: Bug fix
- [ ] docs: Documentation update
- [ ] refactor: Code refactoring
- [ ] test: Adding tests
- [ ] chore: Maintenance

## Changes Made
- `file1.dart`: description of change
- `file2.dart`: description of change

## Testing
- [ ] `flutter analyze` passes (0 errors)
- [ ] `flutter test` passes
- [ ] Manually tested on Android
- [ ] Manually tested on iOS

## Screenshots (if UI changes)
| Before | After |
|--------|-------|
| screenshot | screenshot |

## Notes
Any important notes for reviewers.
```

---

## ═══════════════════════════════════════
## PHASE 4 — REPOSITORY DOCUMENTATION
## ═══════════════════════════════════════

### 4.1 — Create/Upgrade README.md

Create a professional README.md. Auto-detect the project name, description,
and tech stack from pubspec.yaml and the existing lib/ structure.

The README must include these sections in this exact order:

```markdown
<div align="center">

# [PROJECT NAME]

[One-line description of the app]

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)
[![CI](https://github.com/[USERNAME]/[REPO]/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/[USERNAME]/[REPO]/actions)

[📱 Download](#download) • [✨ Features](#features) •
[🏗 Architecture](#architecture) • [🚀 Getting Started](#getting-started)

</div>

---

## About
[2-3 sentences describing what the app does and who it's for]

## Features
| Feature | Description |
|---------|-------------|
[Auto-detect from existing code/README]

## Architecture
[Describe the architecture found in lib/ — Clean Architecture, MVVM, etc.]

Project structure:
[Auto-generate tree from actual lib/ folder structure]

## Tech Stack
[Auto-detect from pubspec.yaml dependencies]

## Screenshots
[Placeholder table — leave empty if screenshots/ folder doesn't exist]
| Screen 1 | Screen 2 | Screen 3 |
|----------|----------|----------|
| ![](screenshots/screen1.png) | ![](screenshots/screen2.png) | ![](screenshots/screen3.png) |

## Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0

### Installation
[Standard Flutter installation steps]

### Environment Setup
[If .env.example exists, reference it — otherwise create a section]

## Download
[![Download APK](https://img.shields.io/badge/Download-APK-green?style=for-the-badge&logo=android)](../../releases/latest)

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md)

## License
This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.
```

Fill in all placeholders by reading:
- pubspec.yaml → for project name, description, dependencies
- lib/ folder structure → for architecture and features
- Existing README if any → for existing descriptions, keep useful content

### 4.2 — Create LICENSE

If no LICENSE file exists, create `LICENSE` with MIT License content.
Replace [YEAR] with the current year and [AUTHOR] with the GitHub username
found in the remote URL.

### 4.3 — Create .env.example

Create `.env.example` in the root (safe to commit — no real values):

```env
# Copy this file to .env and fill in your values
# NEVER commit the .env file

# AI / ML
GEMINI_API_KEY=your_gemini_api_key_here

# Maps (if applicable)
MAPS_API_KEY=your_maps_api_key_here

# Add any other environment variables your project needs
```

---

## ═══════════════════════════════════════
## PHASE 5 — CODE QUALITY CONFIGURATION
## ═══════════════════════════════════════

### 5.1 — Update analysis_options.yaml

Replace or create `analysis_options.yaml` in the root:

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.gr.dart"
    - "**/*.mocks.dart"
    - build/**
  errors:
    invalid_annotation_target: ignore
  language:
    strict-casts: true
    strict-raw-types: true

linter:
  rules:
    # Style
    - prefer_single_quotes
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_locals
    - prefer_final_fields
    - avoid_unnecessary_containers
    - sized_box_for_whitespace

    # Safety
    - avoid_print
    - avoid_dynamic_calls
    - cancel_subscriptions
    - close_sinks

    # Documentation
    - slash_for_doc_comments

    # Performance
    - use_build_context_synchronously
```

### 5.2 — Add Codecov Configuration

Create `codecov.yml` in the root:

```yaml
coverage:
  status:
    project:
      default:
        target: auto
        threshold: 1%
    patch:
      default:
        target: auto
        threshold: 1%

comment:
  layout: "reach,diff,flags,files"
  behavior: default
  require_changes: false
```

---

## ═══════════════════════════════════════
## PHASE 6 — BRANCH PROTECTION SETUP FILE
## ═══════════════════════════════════════

Create `.github/branch-protection-setup.md` as a reminder:

```markdown
# Branch Protection Setup

After merging this PR, manually apply these settings on GitHub:

## For `main` branch:
Settings → Branches → Add rule → Branch name: main

- [x] Require a pull request before merging
- [x] Require approvals: 1
- [x] Require status checks to pass before merging
  - Required checks: "🔍 Analyze & Test"
- [x] Require branches to be up to date before merging
- [x] Do not allow bypassing the above settings

## For `develop` branch:
Same settings but approvals: 0 (for solo developers)
```

---

## ═══════════════════════════════════════
## PHASE 7 — FINAL VALIDATION
## ═══════════════════════════════════════

Before opening the PR, run these commands and include output in PR description:

```bash
flutter pub get
flutter analyze --no-fatal-infos
```

If analyze reports errors in EXISTING code (not files you created),
do NOT fix them — just list them in the PR under "⚠️ Pre-existing Issues".

---

## ═══════════════════════════════════════
## PULL REQUEST INSTRUCTIONS
## ═══════════════════════════════════════

Open ONE Pull Request targeting `main` with:

**Title:**
`chore: complete GitHub repository optimization — CI/CD, security, docs, community files`

**Description must include:**

```
## 🚀 What This PR Does
Complete repository transformation to production-ready standards.

## ✅ Changes Summary

### 🔒 Security & Cleanup (Phase 1)
- [ ] Removed junk/scratch files from root
- [ ] Audited for exposed secrets
- [ ] Created comprehensive .gitignore

### ⚙️ CI/CD Pipeline (Phase 2)
- [ ] GitHub Actions: analyze + test on every push/PR
- [ ] GitHub Actions: build Android APK on main
- [ ] GitHub Actions: build iOS check on main
- [ ] GitHub Actions: auto-release on version tag

### 📁 Community Files (Phase 3)
- [ ] AGENTS.md — AI agent instructions
- [ ] CONTRIBUTING.md — contributor guide
- [ ] Bug report issue template
- [ ] Feature request issue template
- [ ] Pull request template

### 📚 Documentation (Phase 4)
- [ ] README.md — professional bilingual documentation
- [ ] LICENSE — MIT license
- [ ] .env.example — environment variables template

### 🧹 Code Quality (Phase 5)
- [ ] analysis_options.yaml — strict linting rules
- [ ] codecov.yml — coverage configuration

### 🌿 Branch Protection (Phase 6)
- [ ] branch-protection-setup.md — manual setup guide

## ⚠️ Security Fixes (if any)
[List any secrets found and removed]

## ⚠️ Pre-existing Issues (if any)
[List flutter analyze errors found in existing code — NOT fixed]

## 📋 Next Steps (manual actions required)
1. Add GitHub Secrets: Settings → Secrets → Actions
   - GEMINI_API_KEY (and any other secrets from .env.example)
2. Apply Branch Protection rules (see .github/branch-protection-setup.md)
3. Add repository Topics on GitHub:
   flutter, dart, clean-architecture, bloc, firebase, mobile-app
4. Add screenshots to screenshots/ folder and update README
5. Create first release tag: git tag v1.0.0 && git push --tags
```

---

## ═══════════════════════════════════════
## ABSOLUTE CONSTRAINTS — NEVER VIOLATE
## ═══════════════════════════════════════

1. NEVER modify any file inside `lib/` unless explicitly instructed
2. NEVER modify `pubspec.yaml` or `pubspec.lock`
3. NEVER delete `assets/`, `screenshots/`, `test/` folders
4. NEVER commit any secret, API key, or credential
5. NEVER modify existing `android/` or `ios/` source files
6. NEVER push directly to main — always use a Pull Request
7. If unsure about any file — SKIP it and mention it in PR notes

---

*This prompt was designed to work with any Flutter project regardless of
its current state, size, or architecture.*
