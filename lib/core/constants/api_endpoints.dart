class ApiEndpoints {
  static const String baseUrl = 'https://api.example.com'; // Replace with actual API URL
  
  // Authentication endpoints
  static const String login = '$baseUrl/auth/login';
  
  // OTP endpoints
  static const String sendOtp = '$baseUrl/otp/send';
  static const String verifyOtp = '$baseUrl/otp/verify';
  
  // Employee form endpoints
  static const String submitEmployeeForm = '$baseUrl/employee/submit';
  
  ApiEndpoints._();
}

