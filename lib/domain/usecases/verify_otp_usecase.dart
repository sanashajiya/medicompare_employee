import '../repositories/otp_repository.dart';

class VerifyOtpUseCase {
  final OtpRepository repository;
  
  VerifyOtpUseCase(this.repository);
  
  Future<bool> call({
    required String mobileNumber,
    required String otp,
  }) async {
    return await repository.verifyOtp(
      mobileNumber: mobileNumber,
      otp: otp,
    );
  }
}

