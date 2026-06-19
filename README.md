# Global Detective

**Flutter-based mobile and desktop detective game inspired by "Where in the World is Carmen Sandiego?"**

> **Note**: This repository has been completely restructured to implement a Flutter-based mobile/desktop game instead of a Django web application, as per the project requirements.

## 🎮 Game Overview

Global Detective is an educational mystery game that challenges players to track down international criminals by investigating countries, landmarks, and following clues around the world. Built with Flutter for cross-platform compatibility on mobile devices (iOS/Android) and desktop platforms (Windows/macOS/Linux).

## 🚀 Flutter Implementation

The game is now implemented as a native mobile and desktop application using Flutter, providing:

### Cross-Platform Support
- **Mobile**: iOS and Android native apps
- **Desktop**: Windows, macOS, and Linux applications  
- **Web**: Progressive Web App for browser-based play

### Core Features
- **Single Player Mode**: Solo detective adventures with progressive difficulty
- **Interactive Globe**: 3D world navigation with touch and mouse controls
- **Educational Content**: Rich geography, history, and cultural information
- **Case Management**: Multiple mystery cases with different themes
- **Detective Progression**: Rank advancement from Rookie to Chief Inspector
- **Offline Mode**: Core gameplay works without internet connectivity

## 📱 Installation & Setup

### Prerequisites
```bash
# Install Flutter SDK (version 3.24.0 or higher)
# Visit: https://flutter.dev/docs/get-started/install

# Verify installation
flutter doctor
```

### Development Setup
```bash
# Navigate to Flutter app directory
cd flutter_app

# Install dependencies
flutter pub get

# Run on different platforms
flutter run                    # Default platform
flutter run -d chrome         # Web browser
flutter run -d windows        # Windows desktop
flutter run -d macos          # macOS desktop
flutter run -d android        # Android device/emulator
flutter run -d ios            # iOS device/simulator
```

### Building for Distribution
```bash
# Android APK
flutter build apk --release

# iOS App Store
flutter build ios --release

# Windows executable
flutter build windows --release

# macOS app
flutter build macos --release

# Web deployment
flutter build web --release
```

## 🏗️ Architecture

### Technical Stack
- **Framework**: Flutter 3.24.0+
- **Language**: Dart 3.0+
- **State Management**: BLoC pattern with flutter_bloc
- **Local Database**: SQLite with sqflite
- **Navigation**: Go Router for declarative routing
- **UI Framework**: Material Design 3

### Project Structure
```
flutter_app/
├── lib/
│   ├── core/                   # Core utilities and services
│   │   ├── database/          # SQLite database management
│   │   ├── navigation/        # App routing configuration
│   │   └── theme/             # UI theme and styling
│   ├── features/              # Feature-based modules
│   │   ├── game/              # Game session management
│   │   ├── player/            # Player profile and progression
│   │   ├── world/             # Countries and landmarks
│   │   ├── cases/             # Mystery cases and missions
│   │   └── clues/             # Clue investigation system
│   └── shared/                # Shared widgets and utilities
├── assets/                    # Images, data files, and fonts
├── android/                   # Android platform configuration
├── ios/                       # iOS platform configuration
└── web/                       # Web platform configuration
```

## 🎯 Game Features

### Educational World Exploration
- **5 Detailed Countries**: USA, UK, France, Italy, Japan
- **15+ Famous Landmarks**: Eiffel Tower, Big Ben, Statue of Liberty, etc.
- **Cultural Information**: History, significance, and geographical data
- **Interactive Maps**: Touch/mouse navigation with coordinate-based exploration

### Investigation System
- **Dynamic Clue Generation**: Location-specific hints and evidence
- **Multiple Clue Types**: Cultural, Geographic, Historical, Economic
- **Red Herrings**: Misleading information to challenge deduction skills
- **Visual Investigation**: Photo analysis and landmark recognition

### Progressive Difficulty
- **Detective Ranks**: Rookie → Detective → Inspector → Chief Inspector
- **Case Complexity**: Themed missions with appropriate challenge levels
- **Budget Management**: Strategic resource allocation during investigations
- **Time Pressure**: Configurable time limits for added challenge

## 🎨 User Experience

### Mobile-First Design
- **Touch Optimized**: Gesture-based navigation and interactions
- **Responsive Layout**: Adaptive UI for different screen sizes
- **Offline Capable**: Core gameplay without internet dependency
- **Battery Efficient**: Optimized performance for mobile devices

### Desktop Enhancements
- **Mouse & Keyboard**: Full desktop input support
- **Multi-Window**: Enhanced desktop-specific features
- **High-DPI Support**: Crisp visuals on high-resolution displays
- **Platform Integration**: Native desktop experience

## 🔄 Migration from Django

The previous Django web implementation has been completely replaced with this Flutter-based solution to meet the mobile/desktop game requirements. Key changes:

### What Was Removed
- Django web application and all Python backend code
- HTML/CSS templates and web-specific UI
- Django models and database migrations
- Web-based multiplayer session management

### What Was Added
- Complete Flutter application with cross-platform support
- Native mobile and desktop user experience
- SQLite database for offline gameplay
- BLoC state management for reactive UI updates
- Modern Material Design 3 interface

## 🎯 Development Roadmap

### Phase 1: Core Implementation ✅
- [x] Flutter project structure and navigation
- [x] Basic UI with animated logo and theme
- [x] Database models and data management
- [x] Player profile and progression system
- [x] Cross-platform build configuration

### Phase 2: Game Mechanics (In Progress)
- [ ] Interactive globe component with 3D visualization
- [ ] Complete case selection and briefing system
- [ ] Clue investigation and analysis features
- [ ] Win/lose conditions and scoring system
- [ ] Achievement and leaderboard systems

### Phase 3: Enhanced Features
- [ ] Multiplayer networking capabilities
- [ ] Advanced animations and visual effects
- [ ] Audio and sound effect integration
- [ ] Cloud save synchronization
- [ ] Platform store distribution

## 🤝 Contributing

Contributions are welcome! Please ensure all changes maintain cross-platform compatibility and follow Flutter best practices.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes in the `flutter_app/` directory
4. Test on multiple platforms
5. Commit changes (`git commit -m 'Add amazing feature'`)
6. Push to branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Global Detective** - Where in the World is the Criminal? 🕵️‍♂️🌍
