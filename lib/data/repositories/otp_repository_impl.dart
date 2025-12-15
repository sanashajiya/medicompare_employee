import '../../core/constants/api_endpoints.dart';
import '../../domain/repositories/otp_repository.dart';
import '../datasources/remote/api_service.dart';

class OtpRepositoryImpl implements OtpRepository {
  final ApiService apiService;
  
  OtpRepositoryImpl(this.apiService);
  
  @override
  Future<bool> sendOtp({required String mobileNumber}) async {
    try {
      final response = await apiService.post(
        ApiEndpoints.sendOtp,
        {'mobileNumber': mobileNumber},
      );
      
      return response['success'] == true;
    } catch (e) {
      // For demo purposes, simulate successful OTP sending
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }
  }
  
  @override
  Future<bool> verifyOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    try {
      final response = await apiService.post(
        ApiEndpoints.verifyOtp,
        {
          'mobileNumber': mobileNumber,
          'otp': otp,
        },
      );
      
      return response['success'] == true;
    } catch (e) {
      // For demo purposes, simulate successful OTP verification
      // Accept "123456" as valid OTP
      await Future.delayed(const Duration(seconds: 1));
      return otp == '123456';
    }
  }
}

