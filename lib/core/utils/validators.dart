import 'dart:io';

class Validators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.trim().isEmpty) {
      return 'Confirm password is required';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static final RegExp _mobileRegex = RegExp(r'^[6-9]\d{9}$');
  static String? validateMobileNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }

    if (!_mobileRegex.hasMatch(value)) {
      return 'Enter a valid 10-digit mobile number starting with 6–9';
    }

    // Extra safety check
    if (value == '0000000000') {
      return 'Enter a valid 10-digit mobile number';
    }

    return null;
  }

  static String? validateOptionalMobileNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // optional field
    }

    if (!_mobileRegex.hasMatch(value)) {
      return 'Enter a valid 10-digit mobile number starting with 6–9';
    }

    if (value == '0000000000') {
      return 'Enter a valid 10-digit mobile number';
    }

    return null;
  }

  static String? validateOtp(String? value, {int length = 6}) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP is required';
    }
    if (value.length != length) {
      return 'OTP must be $length digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'OTP must contain only digits';
    }
    return null;
  }

  static String? validateAlphaOnly(
    String? value,
    String fieldName, {
    int minLength = 2,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final trimmedValue = value.trim();

    // Only alphabets and spaces
    final alphaRegex = RegExp(r'^[A-Za-z ]+$');

    if (!alphaRegex.hasMatch(trimmedValue)) {
      return '$fieldName should contain only alphabets';
    }

    if (trimmedValue.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    return null;
  }

  static String? validateAccountNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Account number is required';
    }

    final trimmedValue = value.trim();

    // Digits only
    if (!RegExp(r'^[0-9]+$').hasMatch(trimmedValue)) {
      return 'Account number must contain only digits';
    }

    // Length check (India-safe)
    if (trimmedValue.length < 9 || trimmedValue.length > 18) {
      return 'Account number must be between 9–18 digits';
    }

    // Reject all same digits (000000000, 111111111, etc.)
    if (RegExp(r'^(\d)\1+$').hasMatch(trimmedValue)) {
      return 'Enter a valid account number';
    }

    return null;
  }

  static String? validateConfirmAccountNumber(
    String? accountNumber,
    String? confirmAccountNumber,
  ) {
    if (confirmAccountNumber == null || confirmAccountNumber.trim().isEmpty) {
      return 'Confirm account number is required';
    }
    if (accountNumber != confirmAccountNumber) {
      return 'Account numbers do not match';
    }
    return null;
  }

  static String? validateIfscCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'IFSC code is required';
    }
    final ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
    if (!ifscRegex.hasMatch(value.toUpperCase())) {
      return 'Please enter a valid IFSC code (e.g., SBIN0001234)';
    }
    return null;
  }


  /// Validates file presence + max size
static String? validateFileUpload(
  File? file,
  String fieldName, {
  int maxSizeMB = 5,
}) {
  if (file == null) {
    return '$fieldName is required';
  }

  final maxBytes = maxSizeMB * 1024 * 1024;
  final fileSize = file.lengthSync();

  if (fileSize > maxBytes) {
    return '$fieldName must be less than $maxSizeMB MB';
  }

  return null;
}


  Validators._();
}
