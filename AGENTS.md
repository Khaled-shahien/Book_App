# AGENTS.md

This file provides instructions for AI coding agents (Codex, Jules, etc.).
Read this file completely before starting any task.

## Project
Flutter mobile application with a feature-first architecture.
Stack: Flutter, Dart, GetX, Dio, Firebase Auth, Cloud Firestore, and Material.

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
- main -> stable production code only
- develop -> integration branch
- feat/xxx -> new feature
- fix/xxx -> bug fix
- docs/xxx -> documentation

## Security Rules
NEVER commit: google-services.json, GoogleService-Info.plist,
firebase_options.dart, .env, key.properties, *.keystore, *.jks.
NEVER hardcode API keys in Dart files.

## Protected
Do NOT modify lib/ source code unless explicitly asked.
Do NOT modify pubspec.yaml unless adding a specific requested dependency.
