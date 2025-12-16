class ApiEndpoints {
  static const String baseUrl = 'https://api.medicompares.digitalraiz.co.in/api/v1';

  // Authentication endpoints
  static const String login = '$baseUrl/employeevendor/auth/login';

  // OTP endpoints
  static const String sendOtp = '$baseUrl/otp/send';
  static const String verifyOtp = '$baseUrl/otp/verify';

  // Employee form endpoints
  static const String submitEmployeeForm = '$baseUrl/employee/submit';

  // Vendor endpoints
  static const String createVendor = '$baseUrl/employeevendor/vendor/create';
  static const String getCategories = '$baseUrl/common/medicalcategories';

  ApiEndpoints._();
}
