# Global Detective Flutter Game

A Flutter-based mobile and desktop game inspired by "Where in the World is Carmen Sandiego?". This educational mystery game challenges players to track down international criminals by investigating countries, landmarks, and following clues around the world.

## Features

### Core Game Mechanics
- **Single Player Mode**: Solo detective adventures with case briefings
- **Multiplayer Sessions**: Collaborative investigation with friends
- **Progressive Difficulty**: Rookie → Detective → Inspector → Chief Inspector ranks
- **Time & Budget Management**: Strategic resource allocation during investigations
- **Cross-Platform**: Runs on iOS, Android, Windows, macOS, and Linux

### Educational World Exploration
- **Interactive Globe**: 3D world navigation with touch/mouse controls
- **Rich Geography Data**: Countries with capitals, currencies, populations
- **Cultural Landmarks**: Famous sites with historical and cultural significance
- **Educational Content**: Learn about different cultures, history, and geography

### Investigation System
- **Dynamic Clue Generation**: Location-specific hints and red herrings
- **Multiple Clue Types**: Cultural, Geographic, Historical, Economic evidence
- **Visual Investigation**: Photo analysis and landmark recognition
- **Deduction Logic**: Separate real clues from misleading information

### Cases & Missions
- **Themed Cases**: Art theft, historical artifacts, cultural treasures
- **Difficulty Scaling**: Cases appropriate for different skill levels
- **Suspect Profiles**: Detailed criminal dossiers with visual identification
- **Mission Briefings**: Clear objectives and investigation strategies

## Technical Architecture

### Flutter/Dart Implementation
- **Clean Architecture**: Separation of concerns with proper layering
- **State Management**: BLoC pattern for reactive state handling
- **Local Database**: SQLite for offline game data and progress
- **API Integration**: RESTful backend for multiplayer features
- **Platform Channels**: Native device capabilities integration

### Cross-Platform Features
- **Responsive UI**: Adaptive layouts for mobile and desktop
- **Touch & Mouse**: Dual input system support
- **Offline Mode**: Core gameplay without internet connectivity
- **Cloud Save**: Progress synchronization across devices
- **Platform Notifications**: Game updates and multiplayer invites

## Installation & Setup

### Prerequisites
- Flutter SDK 3.24.0 or higher
- Dart 3.0.0 or higher
- For iOS: Xcode 14.0+
- For Android: Android Studio with SDK 21+
- For Desktop: Platform-specific development tools

### Development Setup
```bash
# Clone the repository
git clone <repository-url>
cd globaldetective/flutter_app

# Install dependencies
flutter pub get

# Run on different platforms
flutter run                    # Default platform
flutter run -d chrome         # Web browser
flutter run -d windows        # Windows desktop
flutter run -d macos          # macOS desktop
flutter run -d linux          # Linux desktop
```

### Building for Distribution
```bash
# Android APK
flutter build apk --release

# iOS App Store
flutter build ios --release

# Windows desktop
flutter build windows --release

# macOS desktop  
flutter build macos --release

# Linux desktop
flutter build linux --release
```

## Game Flow

1. **Welcome Screen**: Choose single player or multiplayer mode
2. **Profile Setup**: Create detective profile with rank progression
3. **Case Selection**: Browse available missions by difficulty
4. **Mission Briefing**: Review suspect profiles and objectives
5. **World Investigation**: Navigate interactive globe and landmarks
6. **Clue Analysis**: Collect and evaluate evidence from locations
7. **Deduction Phase**: Use logic to identify correct suspect
8. **Arrest & Scoring**: Complete mission and earn detective points

## Development Roadmap

### Phase 1: Core Game (Current)
- [x] Flutter project structure
- [x] Basic navigation and UI
- [x] Game data models
- [x] Single player mode
- [ ] Interactive globe component
- [ ] Case management system

### Phase 2: Enhanced Features
- [ ] Multiplayer networking
- [ ] Advanced animations
- [ ] Audio and sound effects
- [ ] Achievement system
- [ ] Leaderboards

### Phase 3: Platform Optimization
- [ ] Desktop-specific UI adaptations
- [ ] Mobile gesture optimization
- [ ] Platform store distribution
- [ ] Cloud save synchronization

## Educational Value

This game provides educational benefits across multiple domains:

- **Geography**: World capitals, countries, landmarks, coordinates
- **History**: Cultural significance of famous locations
- **Critical Thinking**: Logic puzzles and deduction skills
- **Research**: Information gathering and analysis
- **Cultural Awareness**: Global diversity and traditions

## Contributing

We welcome contributions to make Global Detective even better:

1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.