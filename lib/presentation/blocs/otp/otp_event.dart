import 'package:equatable/equatable.dart';

abstract class OtpEvent extends Equatable {
  const OtpEvent();
  
  @override
  List<Object?> get props => [];
}

class SendOtpRequested extends OtpEvent {
  final String mobileNumber;
  
  const SendOtpRequested(this.mobileNumber);
  
  @override
  List<Object?> get props => [mobileNumber];
}

class VerifyOtpRequested extends OtpEvent {
  final String mobileNumber;
  final String otp;
  
  const VerifyOtpRequested({
    required this.mobileNumber,
    required this.otp,
  });
  
  @override
  List<Object?> get props => [mobileNumber, otp];
}

class OtpReset extends OtpEvent {}

