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
├── state/app_state.dart        # All state + ATS engine
├── models/
│   ├── sub_task.dart
│   ├── goal_item.dart
│   ├── pet_look.dart
│   ├── routine.dart
│   └── community_models.dart
├── screens/
│   ├── shell.dart              # Nav + global overlays (reminder, chat)
│   ├── home_screen.dart        # Goal deconstructor + pet + My goals
│   ├── task_screen.dart        # ATS card + mood + progress + task list
│   ├── calendar_screen.dart    # Month grid + routines synced + view-only popup
│   ├── community_screen.dart   # Friends + communities + finder
│   └── shop_screen.dart        # Wallet + pet preview + item grid
├── widgets/
│   ├── pet_widget.dart         # Unified CustomPaint pet
│   ├── glass_card.dart
│   ├── ambient_background.dart
│   ├── profile_button.dart
│   └── settings_button.dart
└── theme/
    ├── colors.dart
    └── text_styles.dart
```

## Setup

```bash
flutter pub get
flutter run
```
