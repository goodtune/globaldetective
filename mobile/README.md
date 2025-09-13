# Global Detective

A collaborative, cross-platform geography mystery game inspired by Carmen Sandiego. Built with Flutter for desktop, tablet, TV, and web platforms with local multiplayer support.

## 🎯 Project Overview

Global Detective is an educational game that combines:
- **Multi-platform Support**: Runs on iOS, Android, macOS, Windows, Linux, and Web
- **Local Multiplayer**: Host/client architecture using local network discovery
- **Responsive Design**: Adaptive UI that works great on phones, tablets, desktops, and TVs  
- **Educational Focus**: Geography, culture, and problem-solving through interactive gameplay

## 🏗️ Architecture

### Project Structure
```
lib/
├── core/                    # Core business logic and services
│   ├── constants/           # App constants and configuration
│   ├── models/              # Core data models
│   ├── services/            # Platform and utility services
│   └── utils/               # Helper utilities
├── features/                # Feature-based organization
│   ├── game/                # Game logic and mechanics
│   ├── networking/          # Multiplayer networking
│   ├── ui/                  # User interface screens and widgets
│   ├── globe/               # 3D globe and geographical features
│   └── detective/           # Detective mechanics and progression
├── shared/                  # Shared components across features
│   ├── widgets/             # Reusable UI components
│   ├── themes/              # App theming and styling
│   └── providers/           # State management providers
└── main.dart               # Application entry point
```

### Technology Stack
- **Framework**: Flutter 3.x with Dart
- **State Management**: Riverpod for reactive state management
- **Networking**: WebSocket-based local multiplayer with discovery
- **UI**: Material Design 3 with responsive layouts
- **Platforms**: iOS, Android, macOS, Windows, Linux, Web

## 🚀 Features Implemented

### ✅ Core Foundation
- Multi-platform project setup with responsive breakpoints
- Platform detection service with device capability detection
- Comprehensive dependency management and build system
- Clean architecture with feature-based organization

### ✅ User Interface
- Responsive layout system that adapts to different screen sizes
- Platform-optimized UI (mobile, tablet, desktop, TV)
- Material Design 3 theming with light/dark mode support
- Splash screen with platform-specific optimizations

### ✅ Networking Foundation
- Local network discovery using UDP multicast
- WebSocket-based game server with host/client architecture
- Session announcement and discovery system
- Basic multiplayer state synchronization

### ✅ State Management
- Riverpod-based state management for game state
- Platform information providers
- Network session management
- Player connection handling

## 🎮 Game Design (Planned)

Based on the detailed specification in `PLAN.md`:

### Core Gameplay
- **Collaborative Mystery Solving**: Players work together to track down villains
- **Cultural Learning**: Clues tied to geography, landmarks, and cultural elements
- **Progressive Difficulty**: Detective ranking system with increasing challenges
- **Dynamic Content**: AI-generated clues with real-world integration

### Multiplayer Features
- **Host Authority**: One device controls game state and progression
- **Local Discovery**: Automatic session discovery on same network
- **Cross-Platform**: Seamless play between different device types
- **Branching Paths**: Players can split up and explore different leads

### Educational Elements
- **Interactive Globe**: 3D navigation with realistic geography
- **Landmark Exploration**: Cultural sites with educational content
- **Research Tools**: In-game browser for investigating clues
- **Progress Tracking**: Case completion and cultural knowledge building

## 🛠️ Development Setup

### Prerequisites
- Flutter SDK 3.x or later
- Dart SDK (included with Flutter)
- Platform-specific development tools:
  - Xcode (for iOS/macOS)
  - Android Studio (for Android)
  - Visual Studio (for Windows)

### Getting Started
```bash
# Install dependencies
flutter pub get

# Generate code (JSON serialization, etc.)
dart run build_runner build

# Run on your preferred platform
flutter run                    # Default platform
flutter run -d macos          # macOS
flutter run -d chrome         # Web
flutter run -d android        # Android
```

### Building for Production
```bash
# Build for specific platforms
flutter build macos           # macOS app
flutter build windows         # Windows app  
flutter build linux           # Linux app
flutter build web            # Web app
flutter build apk            # Android APK
flutter build ipa            # iOS app
```

## 📱 Platform Capabilities

| Feature | Mobile | Tablet | Desktop | TV | Web |
|---------|--------|--------|---------|----|-----|
| Local Network | ✅ | ✅ | ✅ | ✅ | ❌ |
| File System | ✅ | ✅ | ✅ | ✅ | ❌ |
| Multi-Window | ❌ | ✅ | ✅ | ❌ | ✅ |
| Touch Input | ✅ | ✅ | ✅ | ❌ | ✅ |
| Keyboard/Mouse | ❌ | ✅ | ✅ | ✅ | ✅ |

## 🗺️ Current Status

The project currently has a **solid foundation** with:
- ✅ Complete multi-platform project structure
- ✅ Responsive UI framework
- ✅ Platform detection and adaptation
- ✅ Basic networking infrastructure
- ✅ State management foundation
- ✅ Build system and toolchain

**Ready for game feature development:**
- 🎯 Globe visualization and interaction
- 🎯 Case and clue system implementation
- 🎯 Multiplayer game flow
- 🎯 Educational content integration
- 🎯 Audio and visual polish

---

*Global Detective - Solve mysteries, explore the world, learn together!* 🕵️‍♀️🌍
