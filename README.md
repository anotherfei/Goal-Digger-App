# Goal Digger — Flutter App

AI-driven productivity app with adaptive task scheduling, unified pet companion, and community features.

## Architecture

- **5 tabs**: Home, Task, Calendar, Community, Customize Pet
- **ATS engine**: Scores subtasks by goal importance, deadline urgency, day match, and energy level
- **Unified pet character**: Synced across all pages via `PetWidget`, reflects selected skin
- **Routines**: Synced to calendar grid and day popups as reminders (not tasks)
- **Community**: Friends + Groups with add/remove/join/create + suggestion lists that shrink on action
- **Breakdown chat**: After deconstructing a goal, AI chat overlay to refine the plan

## Files

```
lib/
├── main.dart
├── app/
│   ├── goal_digger_app.dart
│   └── goal_digger_root.dart
├── models/
├── core/
├── data/
├── shared/
│   └── widgets/
└── features/
    ├── onboarding/
    ├── planner/
    ├── calendar/
    ├── tasks/
    ├── community/
    ├── companion/
    ├── focus/
    └── settings/
```

## Setup

```bash
flutter pub get
flutter run
```
