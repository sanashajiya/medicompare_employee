import 'package:equatable/equatable.dart';

abstract class OtpState extends Equatable {
  const OtpState();
  
  @override
  List<Object?> get props => [];
}

class OtpInitial extends OtpState {}

class OtpSending extends OtpState {}

class OtpSent extends OtpState {
  final String message;
  
  const OtpSent([this.message = 'OTP sent successfully']);
  
  @override
  List<Object?> get props => [message];
}

class OtpSendFailure extends OtpState {
  final String error;
  
  const OtpSendFailure(this.error);
  
  @override
  List<Object?> get props => [error];
}

class OtpVerifying extends OtpState {}

class OtpVerified extends OtpState {
  final String message;
  
  const OtpVerified([this.message = 'OTP verified successfully']);
  
  @override
  List<Object?> get props => [message];
}

class OtpVerificationFailure extends OtpState {
  final String error;
  
  const OtpVerificationFailure(this.error);
  
  @override
  List<Object?> get props => [error];
}

