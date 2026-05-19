import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginWithEmailEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginWithEmailEvent(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class LoginWithGoogleEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}

class LoginWithPhoneEvent extends AuthEvent {
  final String phoneNumber;

  const LoginWithPhoneEvent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class VerifyOtpEvent extends AuthEvent {
  final String verificationId;
  final String otpCode;

  const VerifyOtpEvent(this.verificationId, this.otpCode);

  @override
  List<Object?> get props => [verificationId, otpCode];
}

// Internal events for FirebaseAuth phone verification callbacks
class PhoneAuthCodeSentEvent extends AuthEvent {
  final String verificationId;
  final int? resendToken;

  const PhoneAuthCodeSentEvent(this.verificationId, this.resendToken);

  @override
  List<Object?> get props => [verificationId, resendToken];
}

class PhoneAuthVerificationFailedEvent extends AuthEvent {
  final String error;

  const PhoneAuthVerificationFailedEvent(this.error);

  @override
  List<Object?> get props => [error];
}

class PhoneAuthVerificationCompletedEvent extends AuthEvent {
  final PhoneAuthCredential credential;

  const PhoneAuthVerificationCompletedEvent(this.credential);

  @override
  List<Object?> get props => [credential];
}
