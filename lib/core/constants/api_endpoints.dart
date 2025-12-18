class ApiEndpoints {
  // static const String baseUrl = 'https://api.medicompares.digitalraiz.co.in/api/v1';
  static const String baseUrl = 'http://192.168.0.161:9001/api/v1';

  // Authentication endpointss
  static const String login = '$baseUrl/employeevendor/auth/login';

  // OTP endpoints
  static const String sendOtp = '$baseUrl/otp/send';
  static const String verifyOtp = '$baseUrl/otp/verify';

  // Employee form endpoints
  // static const String submitEmployeeForm = '$baseUrl/employeevendor/vendor/profile/send-otp';

  // Vendor endpoints
  static const String createVendor = '$baseUrl/employeevendor/vendor/create';
  static const String sendVendorProfileOtp =
      '$baseUrl/employeevendor/vendor/profile/send-otp';
  // static const String verifyVendorProfileOtp =
  //     '$baseUrl/employeevendor/vendor/profile/verify-otp';
  static const String getCategories = '$baseUrl/common/medicalcategories';
  static const String getDashboard = '$baseUrl/employeevendor/dashboard';

  ApiEndpoints._();
}
