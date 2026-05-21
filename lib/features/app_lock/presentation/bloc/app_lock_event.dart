import 'package:equatable/equatable.dart';

/// Base class for all AppLock BLoC events
abstract class AppLockEvent extends Equatable {
  const AppLockEvent();

  @override
  List<Object?> get props => [];
}

/// Check if app lock is enabled (on app start)
class CheckAppLockStatus extends AppLockEvent {}

/// User enters a PIN digit
class EnterPinDigit extends AppLockEvent {
  final String digit;
  const EnterPinDigit(this.digit);

  @override
  List<Object?> get props => [digit];
}

/// User deletes last PIN digit
class DeletePinDigit extends AppLockEvent {}

/// User clears entire PIN input
class ClearPin extends AppLockEvent {}

/// Authenticate using biometrics
class AuthenticateWithBiometrics extends AppLockEvent {}

/// Enable app lock with a new PIN
class EnableAppLock extends AppLockEvent {
  final String pin;
  const EnableAppLock(this.pin);

  @override
  List<Object?> get props => [pin];
}

/// Save PIN code with security question and answer
class SavePinWithSecurity extends AppLockEvent {
  final String pin;
  final String question;
  final String answer;

  const SavePinWithSecurity({
    required this.pin,
    required this.question,
    required this.answer,
  });

  @override
  List<Object?> get props => [pin, question, answer];
}

/// Disable app lock entirely
class DisableAppLock extends AppLockEvent {
  final String pin;
  const DisableAppLock(this.pin);

  @override
  List<Object?> get props => [pin];
}

/// Recover PIN using security question/answer
class ResetPinWithSecurity extends AppLockEvent {
  final String answer;
  final String newPin;

  const ResetPinWithSecurity({
    required this.answer,
    required this.newPin,
  });

  @override
  List<Object?> get props => [answer, newPin];
}

/// Toggle biometric authentication on/off
class ToggleBiometric extends AppLockEvent {
  final bool enabled;
  const ToggleBiometric(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Mark app as unlocked (after successful auth)
class UnlockApp extends AppLockEvent {}

/// Reset the lock state when app goes to background
class LockApp extends AppLockEvent {}
