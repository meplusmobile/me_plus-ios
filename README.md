# Me Plus - Student Behavior Management System

<div align="center">
  <img src="assets/images/logo.png" alt="Me Plus Logo" width="200"/>
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

## 📱 Overview

**Me Plus** is a comprehensive mobile application designed to manage and track student behavior, activities, and achievements in educational institutions. The app provides a gamified approach to behavior management with a reward system, real-time notifications, and multi-language support (Arabic & English).

### ✨ Key Features

- 🎯 **Behavior Tracking**: Monitor student behaviors with positive, negative, and mixed classifications
- 🏆 **Reward System**: Students can earn points and claim rewards for good behavior
- 📊 **Activity Calendar**: Visual calendar displaying daily behavior indicators
- 🔔 **Real-time Notifications**: Instant updates on behaviors, tasks, and rewards
- 🌍 **Bilingual Support**: Seamless Arabic-English translation with auto-detection
- 📈 **Weekly Streaks**: Track consecutive positive behavior with streak counters
- 🎁 **Store System**: Students can purchase rewards using earned points
- 👤 **Profile Management**: Customizable profiles with avatar upload

## 🏗️ Architecture

The application follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                    # Core utilities and services
│   ├── constants/          # API endpoints, app constants
│   ├── localization/       # Multi-language support
│   └── services/           # Translation, prefetch services
├── data/                   # Data layer
│   ├── models/            # Data models (Activity, Notification, etc.)
│   ├── repositories/      # Data repositories
│   └── services/          # API services (Auth, API client)
├── presentation/          # UI layer
│   ├── providers/        # State management (Provider)
│   ├── screens/          # App screens
│   └── widgets/          # Reusable widgets
└── routes/               # Navigation configuration
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/fadihamad40984/me_plus.git
   cd me_plus
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For development
   flutter run

   # For specific platform
   flutter run -d android
   flutter run -d ios
   flutter run -d windows
   ```

### Building for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Windows
flutter build windows --release
```

## 📦 Dependencies

### Core Dependencies
- **flutter**: UI framework
- **provider**: State management
- **dio**: HTTP client for API calls
- **shared_preferences**: Local data persistence
- **intl**: Internationalization and date formatting

### UI Components
- **table_calendar**: Calendar widget for activity tracking
- **image_picker**: Profile picture selection
- **flutter_svg**: SVG image support

### API Integration
- **Google Translate API**: Automatic text translation
- **Azure Blob Storage**: Image hosting

## 🎨 Design System

### Color Palette
- **Primary Orange**: `#FAA72A`
- **Success Green**: `#4CAF50`
- **Error Red**: `#FF4444`
- **Background**: `#F8F8F8`
- **Text Primary**: `#2E2E2E`
- **Text Secondary**: `#8B8B8B`

### Typography
- **Font Family**: Poppins
- **Heading**: 20px, Semi-Bold (600)
- **Body**: 14-16px, Regular (400)
- **Caption**: 12px, Regular (400)

## 🌐 API Integration

The app connects to a RESTful backend API hosted on Azure:

**Base URL**: `https://meplus3-hjfehnfpfyg2gyau.israelcentral-01.azurewebsites.net`

### Main Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/auth/login` | POST | User authentication |
| `/api/notifications` | GET | Fetch notifications |
| `/api/activity` | GET | Get monthly activity data |
| `/api/behaviors` | GET | Get daily behaviors |
| `/api/behavior-streak/claim-reward` | POST | Claim behavior reward |
| `/api/store/items` | GET | Fetch store items |

## 🔐 Authentication

The app uses JWT-based authentication:

1. User logs in with email/password
2. Server returns JWT token
3. Token stored in SharedPreferences
4. Token included in all API requests via Dio interceptor
5. Auto-refresh mechanism for expired tokens

## 🌍 Internationalization

### Auto-Translation System

The app features an intelligent auto-translation system:

- **Language Detection**: Automatically detects if text is Arabic or English
- **Google Translate Integration**: Uses unofficial Google Translate API
- **Caching**: Translated text cached to minimize API calls
- **Fallback**: If translation fails, original text is displayed

### Supported Languages

- **Arabic (العربية)**: Right-to-left (RTL) layout support
- **English**: Default language

## 📊 Features in Detail

### 1. Behavior Management
- Visual indicators for positive (green), negative (red), and mixed (orange) behaviors
- Weekly behavior tracking with streak counters
- Detailed behavior notes from teachers
- Behavior history calendar view

### 2. Reward System
- Point-based reward system
- Claimable rewards for behavior streaks
- In-app store for purchasing items
- Approval workflow for reward requests

### 3. Notifications
- Real-time push notifications
- Categorized notifications (behavior, task, reward)
- Mark as read/unread functionality
- Swipe to delete notifications
- Custom notification images from backend

### 4. Activity Calendar
- Month-by-month view of all activities
- Color-coded behavior indicators
- Day selection to view detailed behaviors
- Empty state with visual feedback

### 5. Profile Management
- Avatar upload to Azure Blob Storage
- Student information display
- Points and level tracking
- Settings and preferences

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (iOS 12+)
- ✅ Windows (10+)
- ⏳ Web (Coming soon)
- ⏳ macOS (Coming soon)
- ⏳ Linux (Coming soon)

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter format` before committing
- Write meaningful commit messages
- Add comments for complex logic

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Fadi Hamad** - [@fadihamad40984](https://github.com/fadihamad40984)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Google Translate API for translation services
- Azure for cloud storage
- All contributors and testers

## 📧 Contact

For questions or support, please contact:
- Email: fadih40984@gmail.com
- GitHub: [@fadihamad40984](https://github.com/fadihamad40984)

## 🗺️ Roadmap

- [ ] Push notifications support
- [ ] Offline mode with local database
- [ ] Parent portal integration
- [ ] Teacher dashboard
- [ ] Analytics and reporting
- [ ] Dark mode support
- [ ] Multi-school support
- [ ] Gamification enhancements

---

<div align="center">
  Made with ❤️ using Flutter
</div>
