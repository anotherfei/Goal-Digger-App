# Goal Digger — Firebase + Gemma 4 Integration Guide

## Overview

This integration adds two cloud services to the Goal Digger Flutter app:

| Service | Purpose |
|---|---|
| **Firebase Firestore** | Cloud database — syncs goals, tasks, communities and user profiles across devices in real time |
| **Firebase Auth** | User sign-in (anonymous guest, email/password) |
| **Google Cloud Vertex AI – Gemma 4** | AI-powered task planning, motivation, progress reviews and companion chat |

---

## Folder structure added

```
lib/
└── services/
    ├── firebase/
    │   ├── firebase_config.dart       ← Firebase init + shared instances
    │   ├── firebase_models.dart       ← Firestore ↔ app model serialization
    │   ├── goal_repository.dart       ← Goals + tasks CRUD
    │   ├── user_repository.dart       ← Auth + user profile CRUD
    │   ├── community_repository.dart  ← Community groups CRUD
    │   └── index.dart                 ← Barrel export
    └── ai/
        ├── gemma_service.dart         ← Low-level Vertex AI HTTP client
        ├── ai_models.dart             ← Request / response data classes
        ├── ai_prompts.dart            ← All prompt templates (centralised)
        ├── goal_ai_assistant.dart     ← High-level AI features
        └── index.dart                 ← Barrel export

lib/main_updated.dart                  ← Rename to main.dart (replaces original)
pubspec_additions.yaml                 ← Dependencies to add to pubspec.yaml
firestore.rules                        ← Security rules (deploy to Firebase)
docs/SETUP.md                          ← This file
```

---

## Step 1 — Add Flutter dependencies

Open `pubspec.yaml` and add under `dependencies:`:

```yaml
firebase_core: ^3.6.0
cloud_firestore: ^5.4.4
firebase_auth: ^5.3.1
googleapis_auth: ^1.6.0
http: ^1.2.2
```

Then run:

```bash
flutter pub get
```

---

## Step 2 — Create a Firebase project

1. Go to [console.firebase.google.com](https://console.firebase.google.com) and click **Add project**.
2. Enable **Firestore Database** (start in **test mode**, then deploy the provided `firestore.rules` before going to production).
3. Enable **Authentication** and turn on **Anonymous** and **Email/Password** sign-in methods.

---

## Step 3 — Connect Flutter to Firebase

Install the FlutterFire CLI (once per machine):

```bash
dart pub global activate flutterfire_cli
```

From your project root:

```bash
flutterfire configure
```

Select your Firebase project when prompted. This generates:

```
lib/firebase_options.dart   ← auto-generated, do NOT edit manually
```

The `firebase_config.dart` file already imports this file.

---

## Step 4 — Enable Vertex AI (Gemma 4)

### 4a — Enable the API

```
https://console.cloud.google.com/apis/library/aiplatform.googleapis.com
```

Click **Enable** for the project attached to your Firebase project.

### 4b — Create a service account

1. Go to **IAM & Admin → Service Accounts** in the GCP console.
2. Click **Create Service Account**.
3. Name it `goal-digger-ai` and grant it the **Vertex AI User** role.
4. Click **Create Key → JSON** and download the file.

### 4c — Add the key to your Flutter project

```
assets/
└── service_account.json   ← rename your downloaded JSON file to this
```

Declare it in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/service_account.json
```

> ⚠️ **Security**: Add `assets/service_account.json` to `.gitignore`.
> For production apps use Firebase App Check + backend proxy instead.

### 4d — Update main.dart

In `lib/main_updated.dart` (rename to `main.dart`), replace the placeholder values:

```dart
gemmaService = GemmaService(
  projectId: 'your-actual-gcp-project-id',
  location: 'us-central1',       // verify Gemma 4 availability in your region
  modelId: 'gemma-4-27b-it',     // or 'gemma-4-12b-it' for a faster model
);
```

---

## Step 5 — Deploy Firestore security rules

```bash
firebase deploy --only firestore:rules
```

---

## Step 6 — Using the services in your widgets

### Firebase — save & stream goals

```dart
import 'package:goal_digger/services/firebase/index.dart';

final repo = GoalRepository();

// Stream goals into a StreamBuilder
StreamBuilder<List<GoalProject>>(
  stream: repo.watchGoals(),
  builder: (context, snapshot) { ... },
);

// Save a new goal
await repo.saveGoal(myGoal);

// Mark a task done
await repo.markTaskDone(goalId, taskId, done: true);
```

### Auth — sign in

```dart
final userRepo = UserRepository();

// Guest sign-in (no password needed)
await userRepo.signInAnonymously();

// Watch the signed-in user
userRepo.authStateChanges.listen((user) { ... });
```

### Gemma AI — generate task plan

```dart
import 'package:goal_digger/services/ai/index.dart';

// goalAI is the global singleton from main.dart
final plan = await goalAI.generateTaskPlan(
  goal: myGoalProject,
  today: DateTime.now(),
);

for (final task in plan.tasks) {
  print('${task.title} — ${task.durationMinutes} min (${task.load})');
}
```

### Gemma AI — streaming companion chat

```dart
final buffer = StringBuffer();

await for (final token in goalAI.chat(
  userMessage: 'I feel tired today.',
  userName: 'Alex',
  mood: 'Tired',
  streak: 7,
  coins: 140,
  petHappiness: 62,
  petName: 'Minty',
)) {
  buffer.write(token);
  setState(() => _chatReply = buffer.toString());
}
```

---

## AI features at a glance

| Method | Feature | Where to wire it |
|---|---|---|
| `generateTaskPlan` | Break a goal into micro-tasks | Goal creation / edit flow |
| `getMotivation` | Daily motivational card | Home / planner page |
| `reviewProgress` | Coach-style weekly review | Calendar / settings |
| `chat` (streaming) | Companion page chat | `companion_page.dart` |
| `suggestCommunityPost` | Auto-draft a community post | `community_page.dart` |

---

## Recommended next steps

- Replace the service-account approach with a **backend proxy** (Cloud Functions) before shipping to the App Store — service-account JSON embedded in an app binary is not safe for production.
- Add **Firebase Analytics** for usage tracking.
- Add **Firebase Crashlytics** for error reporting.
- Consider **riverpod** or **bloc** to manage the repository streams cleanly across the widget tree.
