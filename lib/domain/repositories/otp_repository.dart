abstract class OtpRepository {
  Future<bool> sendOtp({required String mobileNumber});
  Future<bool> verifyOtp({
    required String mobileNumber,
    required String otp,
  });
}

