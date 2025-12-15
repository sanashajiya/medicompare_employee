import '../repositories/otp_repository.dart';

class SendOtpUseCase {
  final OtpRepository repository;
  
  SendOtpUseCase(this.repository);
  
  Future<bool> call({required String mobileNumber}) async {
    return await repository.sendOtp(mobileNumber: mobileNumber);
  }
}

