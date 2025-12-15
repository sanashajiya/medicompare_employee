import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/send_otp_usecase.dart';
import '../../../domain/usecases/verify_otp_usecase.dart';
import 'otp_event.dart';
import 'otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  
  OtpBloc({
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
  }) : super(OtpInitial()) {
    on<SendOtpRequested>(_onSendOtpRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<OtpReset>(_onOtpReset);
  }
  
  Future<void> _onSendOtpRequested(
    SendOtpRequested event,
    Emitter<OtpState> emit,
  ) async {
    emit(OtpSending());
    
    try {
      final success = await sendOtpUseCase(mobileNumber: event.mobileNumber);
      if (success) {
        emit(const OtpSent('OTP sent to your mobile number'));
      } else {
        emit(const OtpSendFailure('Failed to send OTP'));
      }
    } catch (e) {
      emit(OtpSendFailure(e.toString()));
    }
  }
  
  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<OtpState> emit,
  ) async {
    emit(OtpVerifying());
    
    try {
      final success = await verifyOtpUseCase(
        mobileNumber: event.mobileNumber,
        otp: event.otp,
      );
      if (success) {
        emit(const OtpVerified('Mobile number verified successfully'));
      } else {
        emit(const OtpVerificationFailure('Invalid OTP'));
      }
    } catch (e) {
      emit(OtpVerificationFailure(e.toString()));
    }
  }
  
  void _onOtpReset(OtpReset event, Emitter<OtpState> emit) {
    emit(OtpInitial());
  }
}

