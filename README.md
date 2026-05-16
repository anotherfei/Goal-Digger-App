# Goal Digger — Flutter App

An AI-driven productivity companion that combines adaptive task scheduling, personalized pet companions, and community features to help you achieve your goals efficiently.

## 🎯 Overview

**Goal Digger** is a Flutter-based productivity application designed to help users manage their goals and tasks with an intelligent scheduling engine, engaging pet companion system, and collaborative community features.

## ✨ Key Features

### 📊 Intelligent Task Management
- **Home Dashboard**: Overview of tasks and daily progress
- **Task Manager**: Create, edit, and track individual tasks
- **Adaptive Task Scheduling (ATS)**: Smart algorithm that scores subtasks based on:
  - Goal importance
  - Deadline urgency
  - Day compatibility
  - Current energy level

### 📅 Calendar Integration
- Visual calendar grid with task distribution
- Day popups with detailed task breakdowns
- Routine management synced across the calendar
- Task reminders and scheduling

### 👥 Community Features
- Friends list with add/remove capabilities
- Group creation and management
- Join/leave community groups
- Suggestion lists that adapt to user actions

### 🐕 Unified Pet Companion
- Persistent pet character synced across all pages
- Pet customization and skin selection
- Pet responds to user activity and progress
- Motivational companion experience

### 💡 Goal Breakdown
- Interactive chat-based goal deconstruction
- AI-assisted planning overlay
- Refine and optimize task breakdown in real-time

### ⚙️ Personalization
- Pet customization page
- Theme and appearance settings
- User preferences and routines management

### 🎮 Focus Mode
- Dedicated focus/productivity timer
- Distraction-free task execution

## 🏗️ Architecture

### Project Structure

```
lib/
├── main.dart                          # Application entry point
├── app/
│   ├── goal_digger_app.dart          # App configuration
│   └── goal_digger_root.dart         # Root navigation widget
├── core/                              # Core functionality
│   ├── constants/                     # App constants
│   ├── theme/                         # Design system & theming
│   └── utils/                         # Utility functions
├── models/                            # Data models
├── data/                              # Data layer (API, local storage)
├── shared/                            # Shared resources
│   └── widgets/                       # Reusable UI components
└── features/                          # Feature modules
    ├── onboarding/                    # User onboarding flow
    ├── planner/                       # Goal & plan management
    ├── calendar/                      # Calendar feature
    ├── tasks/                         # Task management
    ├── community/                     # Social features
    ├── companion/                     # Pet companion system
    ├── focus/                         # Focus/timer mode
    ├── responsive/                    # Responsive design utilities
    └── settings/                      # App settings & preferences
```

### Navigation Structure

The app uses a 5-tab bottom navigation structure:
1. **Home** - Dashboard and quick overview
2. **Planner** - Goal management and task creation
3. **Calendar** - Calendar view and scheduling
4. **Community** - Friends, groups, and social features
5. **Companion** - Pet customization and companion

## 🚀 Getting Started

### Prerequisites

- Flutter SDK: `>=3.3.0 <4.0.0`
- Dart SDK: Included with Flutter
- Compatible with Android, iOS, Web, Windows, macOS, and Linux

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Goal-Digger-App
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

```bash
# Android
flutter build apk
flutter build appbundle

# iOS
flutter build ios

# Web
flutter build web

# Windows/macOS/Linux
flutter build windows
flutter build macos
flutter build linux
```

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🛠️ Development

### Project Dependencies

- **flutter**: UI framework
- **flutter_lints**: Dart linting rules

### Code Standards

- Follow Dart style guide conventions
- Use meaningful variable and function names
- Document complex logic with comments
- Maintain separation of concerns across features

### File Organization

Each feature module follows this structure:
```
feature_name/
├── models/           # Data models specific to feature
├── widgets/          # Feature UI components
├── services/         # Business logic and API calls
├── state/            # State management
└── screens/          # Full-page widgets
```

## 📊 Task Scheduling Algorithm

The Adaptive Task Scheduling (ATS) engine prioritizes subtasks using:
- **Importance Score**: Based on parent goal priority
- **Urgency Score**: Based on deadline proximity
- **Match Score**: Based on user's schedule and energy level
- **Energy Level**: Current user energy affects task difficulty recommendations

## 🎨 Design

The app uses Material Design 3 with customizable themes:
- Consistent component library in `shared/widgets`
- Centralized theme configuration in `core/theme`
- Responsive design utilities for various screen sizes

## 📝 License

This project is proprietary. Please contact the development team for licensing information.

## 👨‍💻 Contributing

For contribution guidelines, please contact the project maintainers.

## 🐛 Bug Reports & Feature Requests

Found a bug or have a feature request? Please open an issue in the project repository.
