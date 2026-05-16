# Goal Digger

> An AI-driven productivity companion that combines intelligent task scheduling, personalized pet companions, and community features to help you achieve your goals.

[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.3.0-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%3E%3D3.3.0-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Proprietary-blue)](#license)

## 📋 Table of Contents

- [Features](#-features)
- [Demo](#-demo)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Project Structure](#-project-structure)
- [Architecture](#-architecture)
- [Development](#-development)
- [Contributing](#-contributing)
- [License](#-license)

## ✨ Features

- **📊 Intelligent Task Scheduling** - Adaptive Task Scheduling (ATS) engine that prioritizes tasks based on importance, urgency, schedule fit, and energy levels
- **📅 Calendar Integration** - Visual calendar with task distribution, day popups, and routine management
- **🐕 Pet Companion System** - Personalized pet character that syncs across all pages and responds to your progress
- **👥 Community Features** - Create/join groups, connect with friends, and get suggestions
- **💡 AI-Powered Goal Breakdown** - Chat-based goal decomposition with intelligent planning assistance
- **⚙️ Customization** - Personalize your pet, themes, and productivity settings
- **🎮 Focus Mode** - Distraction-free productivity timer for deep work sessions
- **📱 Multi-Platform** - Works on Android, iOS, Web, Windows, macOS, and Linux

## 🚀 Installation

### Prerequisites

- Flutter SDK `>=3.3.0 <4.0.0`
- Dart SDK (included with Flutter)
- Git

### Clone Repository

```bash
git clone https://github.com/yourusername/goal-digger.git
cd Goal-Digger-App
```

### Get Dependencies

```bash
flutter pub get
```

## 🎯 Quick Start

### Run Development Version

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

# Desktop (Windows/macOS/Linux)
flutter build windows
flutter build macos
flutter build linux
```

## 📁 Project Structure

```
lib/
├── main.dart                          # Application entry point
├── app/
│   ├── goal_digger_app.dart          # App configuration & theme
│   └── goal_digger_root.dart         # Root navigation widget
├── core/
│   ├── constants/                     # App-wide constants
│   ├── theme/                         # Design system & theming
│   └── utils/                         # Utility functions & helpers
├── models/                            # Data models & entities
├── data/                              # Data layer (API, local storage, repositories)
├── shared/
│   └── widgets/                       # Reusable UI components
└── features/
    ├── onboarding/                    # User onboarding & authentication
    ├── planner/                       # Goal creation & management
    ├── calendar/                      # Calendar UI & scheduling
    ├── tasks/                         # Task management & display
    ├── community/                     # Social & community features
    ├── companion/                     # Pet companion system
    ├── focus/                         # Focus/timer functionality
    ├── responsive/                    # Responsive design utilities
    └── settings/                      # App settings & preferences
```

## 🏗️ Architecture

### Navigation Structure (5-Tab Interface)

1. **Home** - Dashboard with daily overview and quick stats
2. **Planner** - Goal creation, breakdown, and task planning
3. **Calendar** - Visual calendar with scheduled tasks and routines
4. **Community** - Friends, groups, and social interactions
5. **Companion** - Pet customization and companion settings

### Core Systems

#### Adaptive Task Scheduling (ATS) Engine
The ATS engine intelligently prioritizes subtasks using:
- **Importance Score** - Based on parent goal priority
- **Urgency Score** - Based on deadline proximity
- **Schedule Compatibility** - Matches available time slots
- **Energy Level** - Adjusts difficulty based on user energy

#### Pet Companion System
- Unified pet character synced across all pages
- Responds to user progress and activity
- Multiple pet skins and customization options
- Persistent state management

#### Community System
- Friends management (add/remove/block)
- Group creation and membership
- Suggestion system with smart filtering
- Activity sharing and notifications

## 💻 Development

### Code Style

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful names for variables, functions, and classes
- Write comments for complex logic
- Maintain feature-module separation

### Project Conventions

- **Models** store data structures and business entities
- **Services** handle API calls and external integrations
- **Widgets** are UI components (stateless/stateful)
- **State Management** centralized in respective features
- **Constants** defined in `core/constants`
- **Themes & Styles** configured in `core/theme`

### Running Tests

```bash
flutter test
```

### Code Analysis

```bash
flutter analyze
```

### Formatting Code

```bash
dart format lib/
```

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure:
- Code follows project style guidelines
- Tests are updated/added as needed
- README is updated if needed
- No breaking changes without discussion

## 📝 License

This project is proprietary software. All rights reserved. Unauthorized copying, modification, or distribution of this software is strictly prohibited.

For licensing inquiries, please contact the project maintainers.

## 🙋 Support

For questions and support:
- Open an issue on GitHub
- Contact the development team
- Check existing documentation

## 🔗 Links

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Material Design 3](https://m3.material.io)
