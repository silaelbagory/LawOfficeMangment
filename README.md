<<<<<<< HEAD
# LawOfficeMangment
=======
# Law Office Management System

A comprehensive Flutter application for managing law office operations with Firebase backend integration, featuring clean architecture, responsive design, and multi-language support.

## 🎯 Features

### Core Functionality
- **Authentication System** - Secure login/logout with Firebase Auth
- **Case Management** - Create, edit, and track legal cases
- **Client Management** - Manage client information and relationships
- **Document Management** - Upload, organize, and access case documents
- **Schedule Management** - Track court dates and appointments
- **Notification System** - Push notifications for important events

### Technical Features
- **Clean Architecture** - Well-structured, maintainable codebase
- **Responsive Design** - Optimized for mobile, tablet, and desktop
- **Multi-language Support** - Arabic and English localization
- **Theme Support** - Light and dark mode with Material 3 design
- **Offline Support** - Firestore caching for offline access
- **Real-time Updates** - Live data synchronization across devices

## 🏗️ Architecture

### Clean Architecture Layers
```
lib/
├── core/                    # Core utilities and constants
│   ├── constants/          # App constants and configurations
│   ├── theme/              # Theme management
│   └── localization/       # Multi-language support
├── domain/                 # Business logic and entities
│   └── entities/           # Data models
├── presentation/           # UI layer
│   ├── blocs/             # State management
│   ├── pages/             # Screen implementations
│   └── widgets/           # Reusable UI components
└── main.dart              # App entry point
```

### State Management
- **BLoC Pattern** - Clean separation of business logic and UI
- **Firebase Integration** - Real-time database and authentication
- **Responsive Design** - Adaptive layouts for all screen sizes

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.7.2 or higher)
- Dart SDK
- Firebase project setup
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd lawofficemanagementsystem
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project
   - Enable Authentication, Firestore, Storage, and Cloud Messaging
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the respective platform folders

4. **Run the application**
   ```bash
   flutter run
   ```

## 📱 Screenshots

### Login Screen
- Modern gradient design
- Theme toggle (light/dark mode)
- Language toggle (Arabic/English)
- Responsive form layout

### Dashboard
- Overview statistics
- Quick navigation cards
- Responsive grid layout
- Real-time data display

## 🔧 Configuration

### Firebase Configuration
```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^4.1.0
  firebase_auth: ^6.0.2
  cloud_firestore: ^6.0.1
  firebase_storage: ^13.0.1
  firebase_messaging: ^16.0.1
  firebase_analytics: ^12.0.1
  firebase_crashlytics: ^5.0.1
```

### Environment Variables
Create a `.env` file in the root directory:
```env
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id
```

## 🌐 Localization

### Supported Languages
- **English (en)** - Default language
- **Arabic (ar)** - Right-to-left support

### Adding New Languages
1. Add new locale to `supportedLocales` in `main.dart`
2. Create translation map in `app_localizations.dart`
3. Update UI components to use localization keys

## 🎨 Theming

### Theme Modes
- **Light Theme** - Clean, professional appearance
- **Dark Theme** - Easy on the eyes for extended use
- **System Default** - Follows device theme preference

### Customization
- Modify colors in `app_constants.dart`
- Update theme data in `app_theme.dart`
- Use consistent spacing and typography constants

## 📊 Data Models

### User Entity
```dart
class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final DateTime createdAt;
  final bool isActive;
}
```

### Case Entity
```dart
class Case {
  final String id;
  final String code;
  final String title;
  final CaseType type;
  final CaseStatus status;
  final String clientId;
  final List<DateTime> hearingDates;
}
```

### Client Entity
```dart
class Client {
  final String id;
  final String name;
  final String? phoneNumber;
  final String? email;
  final List<String> caseIds;
}
```

### Document Entity
```dart
class Document {
  final String id;
  final String name;
  final DocumentType type;
  final String caseId;
  final String fileUrl;
  final int sizeInBytes;
}
```

## 🔐 Security

### Firebase Security Rules
```javascript
// Firestore Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /cases/{caseId} {
      allow read, write: if request.auth != null && 
        (resource.data.assigneeIds[request.auth.uid] != null || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
  }
}
```

### Storage Rules
```javascript
// Storage Rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /documents/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 📱 Responsive Design

### Breakpoints
- **Mobile**: < 600px
- **Tablet**: 600px - 900px
- **Desktop**: 900px - 1200px
- **Large Desktop**: > 1200px

### Implementation
- `ResponsiveWrapper` widget for adaptive layouts
- Flexible grid systems
- Adaptive navigation patterns
- Touch-friendly mobile interfaces

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

### Integration Tests
```bash
flutter test integration_test/
```

## 📦 Build & Deploy

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

### Development Workflow
1. Fork the repository
2. Create a feature branch
3. Implement changes with clean architecture principles
4. Add tests for new functionality
5. Submit a pull request

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistent formatting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [BLoC Documentation](https://bloclibrary.dev/)

### Issues
- Report bugs via GitHub Issues
- Request features through feature requests
- Ask questions in discussions

## 🔮 Roadmap

### Phase 1 (Current)
- ✅ Authentication system
- ✅ Basic dashboard
- ✅ Theme and language support
- ✅ Responsive design

### Phase 2 (Next)
- 🔄 Case management CRUD
- 🔄 Client management
- 🔄 Document upload system
- 🔄 Basic notifications

### Phase 3 (Future)
- 📋 Advanced case tracking
- 📋 Court date management
- 📋 Reporting and analytics
- 📋 Mobile app deployment

### Phase 4 (Advanced)
- 🚀 AI-powered document analysis
- 🚀 Advanced reporting
- 🚀 Integration with court systems
- 🚀 Multi-office support

## 📞 Contact

- **Project Maintainer**: [Your Name]
- **Email**: [your.email@example.com]
- **GitHub**: [@yourusername]

---

**Built with ❤️ using Flutter and Firebase**
>>>>>>> daf5f89 (Initial commit with Firebase Hosting setup)
