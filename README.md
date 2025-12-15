# Medicompare Employee App

A modern Flutter application built with Clean Architecture and BLoC pattern for employee management and form submission.

## Features

### 1. Authentication Screen
- Username and password validation
- Form validation with minimum length requirements
- Login button enabled only when form is valid
- Dummy API integration with loading/success/failure states
- No `setState()` usage - fully BLoC managed

### 2. Employee Form Screen
- Employee information fields (Name, ID, Department, Email)
- Mobile number verification with OTP flow
- Real-time form validation
- Submit button enabled only after OTP verification
- Beautiful, modern UI with Material Design 3

### 3. Mobile Number Verification
- 10-digit mobile number validation
- Send OTP functionality with dummy API
- 6-digit OTP input with custom widget
- OTP verification with success/failure states
- Demo OTP: **123456**

## Architecture

The app follows **Clean Architecture** principles with three main layers:

```
lib/
├── core/                      # Core utilities and configurations
│   ├── constants/            # API endpoints and constants
│   ├── di/                   # Dependency Injection (GetIt)
│   ├── theme/                # App theme, colors, and text styles
│   └── utils/                # Validators and utility functions
│
├── data/                      # Data layer
│   ├── datasources/          # API services
│   │   └── remote/          
│   │       └── api_service.dart
│   ├── models/               # Data models
│   │   ├── employee_model.dart
│   │   └── user_model.dart
│   └── repositories/         # Repository implementations
│       ├── auth_repository_impl.dart
│       ├── employee_repository_impl.dart
│       └── otp_repository_impl.dart
│
├── domain/                    # Domain layer (Business logic)
│   ├── entities/             # Business entities
│   │   ├── employee_entity.dart
│   │   └── user_entity.dart
│   ├── repositories/         # Abstract repositories
│   │   ├── auth_repository.dart
│   │   ├── employee_repository.dart
│   │   └── otp_repository.dart
│   └── usecases/            # Use cases
│       ├── login_usecase.dart
│       ├── send_otp_usecase.dart
│       ├── submit_employee_form_usecase.dart
│       └── verify_otp_usecase.dart
│
└── presentation/              # Presentation layer
    ├── blocs/                # BLoC state management
    │   ├── auth/
    │   │   ├── auth_bloc.dart
    │   │   ├── auth_event.dart
    │   │   └── auth_state.dart
    │   ├── employee_form/
    │   │   ├── employee_form_bloc.dart
    │   │   ├── employee_form_event.dart
    │   │   └── employee_form_state.dart
    │   └── otp/
    │       ├── otp_bloc.dart
    │       ├── otp_event.dart
    │       └── otp_state.dart
    ├── screens/              # UI screens
    │   ├── auth/
    │   │   └── login_screen.dart
    │   └── home/
    │       └── home_screen.dart
    └── widgets/              # Reusable widgets
        ├── custom_button.dart
        ├── custom_text_field.dart
        ├── loading_overlay.dart
        └── otp_input_field.dart
```

## Key Dependencies

- **flutter_bloc**: ^8.1.3 - State management
- **equatable**: ^2.0.5 - Value equality
- **get_it**: ^7.6.4 - Dependency injection
- **http**: ^1.1.0 - HTTP client for API calls
- **formz**: ^0.7.0 - Form validation

## Getting Started

### Prerequisites
- Flutter SDK (>=3.8.1)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd medicompare_employee
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## API Configuration

The app uses dummy API endpoints that can be easily replaced with real ones. Update the endpoints in:

**`lib/core/constants/api_endpoints.dart`**

```dart
class ApiEndpoints {
  static const String baseUrl = 'https://api.example.com'; // Replace this
  
  static const String login = '$baseUrl/auth/login';
  static const String sendOtp = '$baseUrl/otp/send';
  static const String verifyOtp = '$baseUrl/otp/verify';
  static const String submitEmployeeForm = '$baseUrl/employee/submit';
}
```

### Current Behavior (Demo Mode)

Since the dummy APIs don't exist, the app simulates responses:

- **Login**: Any username (min 3 chars) and password (min 6 chars) will succeed
- **Send OTP**: Always succeeds after 1 second delay
- **Verify OTP**: Accepts **123456** as valid OTP
- **Submit Form**: Always succeeds and returns the employee data with a generated ID

## Theme Customization

The app uses a centralized theme system that's easy to customize. All colors and text styles are defined in:

- **Colors**: `lib/core/theme/app_colors.dart`
- **Text Styles**: `lib/core/theme/text_styles.dart`
- **Theme Configuration**: `lib/core/theme/app_theme.dart`

### Current Color Scheme
- Primary: Indigo (#6366F1)
- Secondary: Emerald (#10B981)
- Success: Green (#10B981)
- Error: Red (#EF4444)
- Warning: Amber (#F59E0B)
- Info: Blue (#3B82F6)

To change the theme, simply update the color values in `app_colors.dart`.

## Validation Rules

### Login Form
- **Username**: Required, minimum 3 characters
- **Password**: Required, minimum 6 characters

### Employee Form
- **Employee Name**: Required
- **Employee ID**: Required
- **Department**: Required
- **Email**: Required, valid email format
- **Mobile Number**: Required, exactly 10 digits
- **OTP**: Required, exactly 6 digits

## Reusable Components

### CustomTextField
```dart
CustomTextField(
  controller: controller,
  label: 'Label',
  hint: 'Hint text',
  errorText: errorText,
  keyboardType: TextInputType.text,
  onChanged: (value) {},
)
```

### CustomButton
```dart
CustomButton(
  text: 'Submit',
  onPressed: () {},
  isLoading: false,
  type: ButtonType.primary, // primary, secondary, outlined
  icon: Icons.send,
)
```

### OtpInputField
```dart
OtpInputField(
  length: 6,
  onCompleted: (otp) {
    // Handle OTP completion
  },
  onChanged: (otp) {
    // Handle OTP change
  },
)
```

## State Management

The app uses **BLoC (Business Logic Component)** pattern for state management:

- ✅ No `setState()` usage in UI
- ✅ Clear separation between UI and business logic
- ✅ Testable and maintainable code
- ✅ Reactive programming with streams

### Example BLoC Usage

```dart
BlocProvider(
  create: (_) => sl<AuthBloc>(),
  child: BlocListener<AuthBloc, AuthState>(
    listener: (context, state) {
      if (state is AuthSuccess) {
        // Navigate to home
      } else if (state is AuthFailure) {
        // Show error
      }
    },
    child: BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Build UI based on state
      },
    ),
  ),
)
```

## Testing Demo Credentials

### Login Screen
- **Username**: Any text with 3+ characters (e.g., "demo")
- **Password**: Any text with 6+ characters (e.g., "password123")

### OTP Verification
- **Demo OTP**: `123456`

## Future Enhancements

- [ ] Real API integration
- [ ] JWT token management
- [ ] Persistent storage (local database)
- [ ] Offline mode support
- [ ] Unit and widget tests
- [ ] Integration tests
- [ ] CI/CD pipeline
- [ ] Multi-language support
- [ ] Dark theme support

## Project Structure Benefits

1. **Separation of Concerns**: Each layer has a specific responsibility
2. **Testability**: Business logic is independent of UI and external dependencies
3. **Scalability**: Easy to add new features without affecting existing code
4. **Maintainability**: Clear structure makes code easy to understand and modify
5. **Reusability**: Components and business logic can be reused across the app

## Contributing

1. Follow the existing architecture pattern
2. Use BLoC for state management
3. Create reusable widgets when possible
4. Add proper validation for all forms
5. Update this README when adding new features

## License

This project is part of the Medicompare Employee system.

---

**Built with ❤️ using Flutter and Clean Architecture**
