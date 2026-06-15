# Goal Digger

Goal Digger is a Flutter productivity companion app for Android, backed by Firebase and an agentic AI planning layer built with Genkit and Gemini. The app helps a user turn goals into scheduled micro-tasks, adapt plans around mood and routines, focus without distractions, earn companion rewards, and stay accountable through friends, communities, notifications, and Google Calendar sync.

The repository includes the Flutter client, Firebase Auth/Firestore/Functions integration, Genkit Cloud Functions, Firestore rules/indexes, Android native notification and app-blocking bridges, and generated platform folders. Android is the primary target because focus app blocking and local system notifications depend on Android APIs.

![Goal Digger screenshot](flutter_01.png)

## What The App Does

Goal Digger is organized around five primary app tabs plus modal surfaces for focus, profile, settings, and notifications:

| Area | What is implemented |
| --- | --- |
| Goals | Create goals with deadline, category, and priority; review AI-generated milestone plans before committing; edit deadlines and priority; remove goals; persist goals and embedded tasks in Firestore. |
| Home | Mood check-in, today's scheduled tasks grouped by goal, completion progress, remaining minutes, one-way task completion confirmation, streak and coin rewards. |
| Calendar | Month grid with task/routine dots, daily agenda grouped by goal, recurring routines, routine management, single-task and bulk Google Calendar sync. |
| Social | Full-account social access with public profiles, friend search, direct chats, community creation, join codes, community chat, member detail pages, and leaderboards. |
| Pet | Animated companion, happiness, feeding, companion switching, capsule/gacha unlocks, duplicate refunds, rarity tiers, and per-companion persistence. |
| Focus | Task-linked or custom focus sessions, timer presets/custom duration, pause/resume/minimize/stop, Android persistent timer notification, optional Android Accessibility app blocking, post-session AI insight and rewards. |
| Settings | Light/dark/system theme, account security, email verification, password reset, Google Calendar connection, notification controls, account deletion, sign out. |
| Notifications | In-app inbox with important grouping, unread badge, mark read/all-read, delete, Android settings shortcut, Firestore-backed notification history. |

## Key User Features

### Agentic Goal Planning

- Goal creation starts with a mandatory planning agent call before tasks are created.
- The backend first runs a goal guard that rejects goals that are unclear, too broad, impossible, harmful, or negatively framed.
- The planning agent receives context from the client: category, priority, deadline length, already scheduled daily minutes, mood, streak, and today's task count.
- If the deadline looks unrealistic, the agent suggests a new number of days and asks the user to accept or decline before changing the deadline.
- The agent can generate structured milestones with title, duration, load, and day offset.
- Generated plans are shown in a review dialog before being saved.
- The review dialog supports chat-style plan edits before finalizing.
- Plan modification uses `agentModify`, which can apply changes, ask for clarification, ask for confirmation, or reject unsafe/unrealistic edits.
- If a modification agent call fails, the app can attempt a full re-plan.
- If AI task generation fails after a valid guard/planning path, the app has deterministic fallback task templates.
- If the planning guard itself is unavailable, the app refuses to silently create tasks and asks the user to retry or rewrite the goal.

### Goals And Tasks

- Each goal has a title, category, priority from 1 to 5, deadline, gradient colors, and progress.
- Tasks have a title, duration, scheduled date, point reward, done state, and load:
  - `Light`
  - `Focus`
  - `Stretch`
- Goals calculate progress from completed tasks.
- Task completion is intentionally one-way in the UI and requires confirmation.
- Completing a task gives coins, increases companion happiness, updates streaks, persists the task state, and refreshes notification schedules.
- Goal deletion removes the local goal and attempts to delete the Firestore goal document.
- Goal deadlines and priorities can be edited after creation.

### Mood-Aware Home

- The Home tab tracks mood, today's task count, completed count, progress, and remaining minutes.
- Mood changes persist to the user profile.
- Mood changes call `moodAdvisor`, which produces an AI mood plan and may create an important in-app notification for low-energy moods.
- Mood changes also trigger `agentReassign` so the backend can rebalance unfinished tasks around the user's current capacity.

### Calendar And Routines

- Calendar shows a month grid with task and routine density.
- Selecting a day shows tasks grouped by goal, completion state, load, duration, deadline, and category.
- Users can add routines with title, date, time, and repeat type:
  - yearly
  - monthly
  - weekly
  - daily
  - custom one-off
- Routines are persisted under the user's Firestore document.
- Adding a routine triggers task reassignment because routines are treated as fixed commitments.
- Routines can be viewed in a dedicated full list and deleted.

### Google Calendar Sync

- Users connect Google Calendar from Settings.
- Calendar sync is manual from the Calendar tab.
- A single task can be synced to Google Calendar.
- All tasks can be synced in bulk.
- The sync code checks for existing events before inserting duplicates.
- Task events use private extended properties such as `source`, `goalId`, `taskId`, and `syncKey`.
- The Google Calendar service also includes a routine event helper with `routineId`, `syncKey`, and recurrence support for daily, weekly, monthly, or yearly repeats.
- The current event timezone in the implementation is `Asia/Taipei`.

### Focus Mode

- Focus sessions can be tied to an unfinished goal task or started as a custom session.
- Duration options include task duration, 15, 25, 45, 60 minutes, or a custom value up to 240 minutes.
- The focus dialog supports pause, resume, minimize, and stop.
- The countdown stays accurate when the app resumes from the background.
- On Android, focus mode shows a persistent countdown notification.
- Optional app blocking uses Android Accessibility with explicit user permission.
- The app picker lists launchable apps, supports search, and excludes system/protected packages.
- If a blocked app opens during focus, the accessibility service sends the user back to the home screen and shows a short toast.
- Completed sessions can auto-complete the selected task.
- Completed or stopped sessions call `focusInsight` for a short AI reflection.
- Completed focus sessions can award additional coins based on duration.

### Companion System

- Lumi is the default unlocked companion.
- Additional companions are unlockable through capsule/gacha pulls:
  - Auri
  - Porc
  - Mush
  - Cels
  - Pyro
  - Gbat
  - Nong
- Rarity tiers are common, uncommon, rare, and epic.
- Capsule cost is 100 coins.
- Duplicate pulls refund 50 coins.
- Rarity distribution shown in the UI is:
  - Common: 68%
  - Uncommon: 20%
  - Rare: 10%
  - Epic: 2%
- Feeding a companion costs 10 coins and increases happiness.
- Switching companions applies a small happiness penalty to the previous companion, with a floor.
- Companion happiness decays daily:
  - 10 points after a day with completed work
  - 20 points after a day with no completed work
- Non-default companions can lock again if their happiness reaches zero.
- Streak tiers change the sprite sheet:
  - low: under 7 days
  - mid: 7 to 13 days
  - high: 14 or more days
- Sprite assets include idle and interacted animations for each companion and tier.

### Social And Community

- Guest users can preview the app, but full social features require a non-anonymous account.
- The app creates and maintains public profiles in `public_profiles/{uid}` for search and social display.
- Users can search public profiles and add friends.
- Direct chats are stored under `chats/{chatId}` with a `messages` subcollection.
- Communities are stored under `communities/{communityId}`.
- Users can create communities, join by code, leave communities, or delete owned communities.
- Communities support message threads under `communities/{communityId}/messages`.
- Social notifications are written to recipients' inboxes for friend, chat, and community activity.
- Leaderboards show streak ranking across friends and communities.
- Profile detail pages show progress, achievements, shared communities, streak state, and relationship status.

### Profile And Account Management

- Firebase Auth supports:
  - anonymous guest sign-in
  - Google sign-in
  - email/password sign-in
  - email/password account creation
  - upgrading a guest account to email/password
  - upgrading a guest account to Google
- Guest upgrades preserve the anonymous account where Firebase credential linking succeeds.
- Users can edit display name.
- Users can request email verification.
- Users can refresh email verification status.
- Users can send password reset email.
- Users can delete the current Firebase Auth account.
- Email/password account deletion supports password reauthentication when Firebase requires recent login.

### Notifications

Goal Digger has both in-app notifications and Android system notifications.

In-app notification types:

- daily plan
- task reminder
- streak saver
- deadline warning
- routine reminder
- focus complete
- mood nudge
- reward
- community
- friend
- chat
- important

Implemented notification behavior:

- Firestore-backed inbox under `users/{uid}/notifications`.
- Important unread notifications are grouped at the top of the inbox.
- Top app bar shows unread and important unread state.
- Notifications can be marked read, all marked read, or deleted.
- Important deadline notifications are created when goals are due soon or overdue.
- Android permission problems create an important in-app notification.
- System notification settings are configurable in Settings.
- Android notification scheduling covers daily plans, streak saver nudges, deadline warnings, routine reminders, and focus completion.
- Scheduled Android notifications are restored after boot, app update, time change, or timezone change.
- Firebase Cloud Messaging tokens are saved under `users/{uid}/fcmTokens`.
- Foreground FCM messages can be displayed through the Android notification bridge.

Backend notification agent:

- `sendNotificationPush` runs when an inbox notification is created.
- The agent decides whether to push now or keep the notification inbox-only.
- It considers duplicates, hourly push budget, notification settings, engagement history, importance, and protected social content.
- Reward notifications stay in the inbox.
- Chat, friend, and community push copy is preserved rather than rewritten by the model.
- `learnNotificationEngagement` updates notification-agent memory when notifications are read.

### Theme And Design

- The app uses Plus Jakarta Sans from local assets.
- Light, dark, and system theme modes are available.
- Theme preference is persisted with `shared_preferences`.
- Design tokens live under `lib/core/theme`.
- Shared UI components live under `lib/shared/widgets`.

## AI Backend

The AI backend is implemented in Firebase Functions with Genkit and the Google GenAI plugin.

Default model:

```text
googleai/gemini-2.5-flash
```

Function region:

```text
asia-east1
```

Callable and HTTP functions:

| Function | Type | Purpose |
| --- | --- | --- |
| `goalCoach` | callable | Conversational goal coaching response with suggested actions. Implemented in the backend and typed Flutter wrapper, but not currently exposed as its own standalone screen. |
| `goalCoachStream` | HTTP SSE | Streaming goal coach endpoint with manual Firebase ID token verification. |
| `taskGenerator` | callable | Generates AI micro-tasks for a goal, with deterministic fallback. |
| `moodAdvisor` | callable | Produces mood-aware productivity advice. |
| `focusInsight` | callable | Produces post-focus-session insight and deterministic reward metadata. |
| `agentPlanner` | callable | Full agentic goal planning run: guard, plan, execute tools, reflect, save memory. |
| `agentModify` | callable | Applies or rejects edits to the current draft plan. |
| `agentReassign` | callable | Rebalances unfinished tasks after mood, routine, deadline, priority, or manual context changes. |
| `sendNotificationPush` | Firestore trigger | Runs the notification triage agent when inbox notifications are created. |
| `learnNotificationEngagement` | Firestore trigger | Learns from read notifications and updates notification-agent memory. |

Agent tools:

- `analyzeHabits`: estimates burnout risk, productivity insight, and stronger work hours.
- `createMilestones`: creates structured milestone tasks with duration, load, and day offset.
- `scheduleTasks`: deterministic schedule math for sessions and recommended daily minutes.

Agent hard rules:

- Reject negative, harmful, unclear, impossible, or too-broad goals before task generation.
- Suggest a better deadline when the selected deadline is unrealistic, but ask before changing it.
- Never silently apply risky or ambiguous plan edits.
- Enforce deadline limits in code, not only in prompts.
- Apply reassignment with daily capacity and goal-importance constraints.
- Use deterministic fallbacks when model calls fail.

Agent memory:

- Stored in `agent_memory/{uid}`.
- Written only by backend Admin SDK.
- Readable by the owning user under Firestore rules.
- Tracks last goal, total agent runs, reflection count, preferred work hours, recommended daily minutes, burnout risk, notification engagement, and reassignment audit data.

## Firebase And Data Model

Configured Firebase project in this repo:

```text
projectId: goaldigger-2026
Firestore location: asia-east1
Functions region: asia-east1
```

Primary Firestore collections:

| Path | Purpose |
| --- | --- |
| `users/{uid}` | Profile, streak, coins, companion state, mood, notification settings, preferences, friends, onboarding status. |
| `users/{uid}/goals/{goalId}` | User goals. Tasks are embedded in a `tasksMap` field on the goal document. |
| `users/{uid}/routines/{routineId}` | Calendar routines. |
| `users/{uid}/notifications/{notificationId}` | In-app notifications and notification-agent metadata. |
| `users/{uid}/fcmTokens/{tokenId}` | Firebase Messaging tokens. |
| `users/{uid}/communities/{communityId}` | Per-user community membership records used by repository code. |
| `public_profiles/{uid}` | Searchable social profile. |
| `communities/{communityId}` | Global community documents. |
| `communities/{communityId}/messages/{messageId}` | Community chat messages. |
| `chats/{chatId}` | Direct chat documents. |
| `chats/{chatId}/messages/{messageId}` | Direct chat messages. |
| `agent_memory/{uid}` | Backend-owned AI memory. |

Security rules are in `firestore.rules`.

Indexes are in `firestore.indexes.json`.

Firebase config is in:

- `firebase.json`
- `.firebaserc`
- `lib/firebase_options.dart`
- `android/app/google-services.json`

## Android Native Capabilities

Android platform channels:

| Channel | Dart service | Native implementation |
| --- | --- | --- |
| `goal_digger/notifications` | `AndroidNotificationService` | `MainActivity.kt`, `GoalNotificationScheduler.kt`, receivers |
| `goal_digger/focus_blocking` | `FocusAppBlockingService` | `MainActivity.kt`, `FocusBlockAccessibilityService.kt`, `FocusBlockStore.kt`, `FocusTimerNotification.kt` |

Android permissions and services:

- `POST_NOTIFICATIONS` for Android 13+ notification permission.
- `RECEIVE_BOOT_COMPLETED` to restore scheduled notifications and focus timer state.
- Accessibility service `FocusBlockAccessibilityService` for optional app blocking.
- Package visibility query for launchable apps so the focus app picker can list installed apps.

The Android manifest currently uses:

```text
android:label="fltr_test"
```

Change that label if you want installed builds to display `Goal Digger`.

## Project Structure

```text
.
|-- android/                      Android app, native notification bridge, focus blocker
|-- assets/                       Companion sprite sheets and fonts
|-- functions/                    Firebase Functions, Genkit flows, agents, notification triage
|-- ios/ macos/ linux/ windows/   Generated Flutter platform folders
|-- lib/
|   |-- app/                      App root, shell wiring, goal planning workflow
|   |-- core/                     Constants, theme, date helpers
|   |-- data/                     Seed demo goals
|   |-- features/                 UI features: planner, tasks, calendar, community, companion, focus, profile, settings, notifications
|   |-- firebase/                 Firebase init, auth, Firestore repositories, sync service
|   |-- genkit/                   Flutter wrappers for AI Functions
|   |-- models/                   Shared app models
|   |-- services/                 Google Calendar service
|   |-- shared/                   Shared widgets
|-- firestore.rules               Firestore security rules
|-- firestore.indexes.json        Firestore indexes
|-- firebase.json                 Firebase project configuration
|-- pubspec.yaml                  Flutter dependencies, assets, fonts
```

## Requirements

- Flutter SDK compatible with Dart `>=3.4.0 <4.0.0`.
- Android Studio or Android SDK for Android builds.
- A Firebase project with Auth, Firestore, Functions, App Check, and Firebase Messaging configured.
- Node.js 20 for Firebase Functions.
- Firebase CLI, usually run with `npx -y firebase-tools@latest`.
- A Gemini API key stored as the Firebase Functions secret `GEMINI_API_KEY`.

For Android sign-in with Google, the Firebase Android app must have the correct SHA-1/SHA-256 fingerprints for the debug/release signing keys you use.

For Google Calendar sync, the Google sign-in client must be allowed to request:

```text
https://www.googleapis.com/auth/calendar.events
```

## Install

From the repository root:

```powershell
flutter pub get
```

Install Functions dependencies:

```powershell
cd functions
npm install
cd ..
```

## Run With Real Firebase

The app defaults to real Firebase unless `USE_FIREBASE_EMULATORS` is enabled.

```powershell
flutter run
```

For a release APK:

```powershell
flutter build apk --release
```

Set the Gemini secret before deploying Functions:

```powershell
npx -y firebase-tools@latest functions:secrets:set GEMINI_API_KEY
```

Deploy Firestore rules, indexes, and Functions:

```powershell
npx -y firebase-tools@latest deploy --only firestore,functions
```

## Run With Firebase Emulators

Start Firebase emulators:

```powershell
npx -y firebase-tools@latest emulators:start --only auth,firestore,functions
```

Run Flutter against the local emulators:

```powershell
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
```

Emulator ports from `firebase.json`:

| Emulator | Port |
| --- | --- |
| Auth | `9099` |
| Firestore | `8080` |
| Functions | `5001` |
| Emulator UI | `4000` |

On Android emulators, the app connects to Firebase emulators through `10.0.2.2`.

Debug/profile Android manifests include cleartext network config for emulator traffic. Release configuration disables cleartext traffic.

## Build And Test

Flutter analysis:

```powershell
flutter analyze
```

Flutter tests:

```powershell
flutter test
```

Functions build:

```powershell
cd functions
npm run build
cd ..
```

Functions tests:

```powershell
cd functions
npm test
cd ..
```

The current Functions test suite covers notification triage policy decisions.

## Important Implementation Notes

- Root `README.md` is intentionally the source of truth for the repository overview.
- The app includes generated platform folders, but Android has the most complete native feature support.
- Guest sign-in is anonymous Firebase Auth, not a purely local mode.
- Demo seed goals, routines, friends, and communities are used while signed out or before Firestore sync completes.
- Social features require a full, non-anonymous account unless `kDebugAllowGuestSocialAccess` is changed in code.
- Tasks are embedded under each goal in `tasksMap`; they are not stored in a Firestore task subcollection.
- App Check uses debug providers in non-release builds and Play Integrity/DeviceCheck in production paths.
- `goalCoach` and `goalCoachStream` are implemented and wrapped, but the current visible app flow mainly uses the planning, modification, reassignment, mood, task generation, and focus insight functions.
- The Google Calendar service writes to the user's primary calendar and uses private extended properties to avoid duplicates.
- Android app blocking only works after the user explicitly enables the accessibility service.

## Common Troubleshooting

### Google sign-in fails on Android

Check that the Firebase Auth Google provider is enabled and that the Android app in Firebase has the correct SHA-1/SHA-256 fingerprints for your signing key.

### AI calls fail

Confirm that Functions are deployed in `asia-east1`, the Flutter `GenkitConfig.region` matches that region, and the `GEMINI_API_KEY` secret is available to Functions.

### Firestore writes fail

Deploy the rules and indexes:

```powershell
npx -y firebase-tools@latest deploy --only firestore
```

Then confirm the user is authenticated and writing only to allowed owner paths.

### Android notifications do not appear

Open Settings in the app and use Android notification settings. Android 13+ requires runtime notification permission, and the focus timer channel can also be disabled independently by the OS.

### Focus app blocking does not work

Enable the `Goal Digger App Block` accessibility service from Android Accessibility settings, then return to the focus setup sheet and choose apps to block.

### Emulator networking fails on Android

Use:

```powershell
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
```

The app maps Android emulator traffic to `10.0.2.2` for local Firebase emulators.
