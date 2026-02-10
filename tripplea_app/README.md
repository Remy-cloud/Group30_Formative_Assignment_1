# Study Partner 📚

A Flutter mobile application designed to help students manage their academic life effectively. Track assignments, schedule classes, monitor attendance, and stay organized throughout the semester.

## 📋 Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Setup & Installation](#setup--installation)
- [Running the App](#running-the-app)
- [Technologies Used](#technologies-used)
- [Contributing](#contributing)
- [Team](#team)
- [License](#license)

## ✨ Features

### 📊 Dashboard
- Overview of upcoming assignments and today's classes
- Quick stats on attendance percentage
- Current academic week display
- Low attendance warnings (below 75%)

### 📝 Assignment Management
- Add, edit, and delete assignments
- Set due dates and priority levels (High, Medium, Low)
- Mark assignments as complete
- Filter by course name
- View assignments due in the next 7 days

### 📅 Schedule Management
- Weekly class schedule view
- Add academic sessions (lectures, labs, tutorials)
- Track attendance for each session
- Navigate between weeks

### 👤 Profile
- User profile with name, email, and program
- Edit profile information
- Logout functionality
- Data persistence across app sessions

## 🏗️ Architecture

This app follows a **Provider-based state management** architecture:

```
┌─────────────────────────────────────────────────────┐
│                      UI Layer                        │
│   (Screens: Dashboard, Assignments, Schedule, etc.) │
└─────────────────────────┬───────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────┐
│                  State Management                    │
│              (DataProvider + Provider)               │
└─────────────────────────┬───────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────┐
│                   Data Layer                         │
│    (SharedPreferences for local persistence)         │
└─────────────────────────────────────────────────────┘
```

### Key Components:

- **DataProvider**: Central state manager that handles all CRUD operations for assignments and sessions
- **Models**: Data classes (`Assignment`, `AcademicSession`) with JSON serialization
- **Screens**: UI components that consume and display data from the provider
- **Theme**: Centralized app theming with custom colors

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point & navigation
├── datastorage/
│   └── data_provider.dart    # State management & data persistence
├── models/
│   ├── assignment.dart       # Assignment data model
│   └── academic_session.dart # Academic session data model
├── screens/
│   ├── dashboard_screen.dart    # Home dashboard
│   ├── assignments_screen.dart  # Assignment management
│   ├── schedule_screen.dart     # Weekly schedule view
│   └── profile_screen.dart      # User profile
└── theme/
    └── app_theme.dart        # App colors and theming
```

## 🚀 Setup & Installation

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- Android Studio / VS Code with Flutter extensions
- An Android emulator, iOS simulator, or physical device

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/Remy-cloud/Group30_Formative_Assignment_1.git
   cd Group30_Formative_Assignment_1/tripplea_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Verify Flutter setup**
   ```bash
   flutter doctor
   ```

## ▶️ Running the App

### On Android Emulator
```bash
flutter run
```

### On iOS Simulator (macOS only)
```bash
flutter run -d ios
```

### On Chrome (Web)
```bash
flutter run -d chrome
```

### Build for Release

**Android APK:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## 🛠️ Technologies Used

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform UI framework |
| **Dart** | Programming language |
| **Provider** | State management |
| **SharedPreferences** | Local data persistence |
| **Material Design 3** | UI components and theming |

### Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  shared_preferences: ^2.0.0
```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the repository**

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow Dart/Flutter coding conventions
   - Add comments for complex logic
   - Test your changes thoroughly

4. **Commit your changes**
   ```bash
   git commit -m "Add: description of your feature"
   ```

5. **Push to your branch**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Open a Pull Request**
   - Describe your changes clearly
   - Reference any related issues

### Coding Guidelines

- Use meaningful variable and function names
- Follow the existing project structure
- Add documentation for new features
- Ensure no lint errors (`flutter analyze`)

## 👥 Team

**Group 30** - Formative Assignment 1

## 📄 License

This project is created for educational purposes as part of a formative assignment.

---

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/language)
- [Provider Package](https://pub.dev/packages/provider)
- [Material Design 3](https://m3.material.io/)
