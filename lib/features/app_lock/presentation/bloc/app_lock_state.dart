import 'package:equatable/equatable.dart';

/// Enum representing the current purpose of the lock screen
enum LockScreenMode {
  /// Unlock the app (user must verify PIN / biometric)
  unlock,
  /// Setup a new PIN
  setup,
  /// Confirm the new PIN during setup
  confirm,
}

/// Base class for all AppLock BLoC states
abstract class AppLockState extends Equatable {
  const AppLockState();

  @override
  List<Object?> get props => [];
}

/// Initial state - checking lock status
class AppLockInitial extends AppLockState {}

/// App lock is not enabled - no lock screen needed
class AppLockDisabled extends AppLockState {}

/// App is locked - show lock screen
class AppLocked extends AppLockState {
  final LockScreenMode mode;
  final String enteredPin;
  final String? firstPin; // Stored during confirm step
  final bool isBiometricAvailable;
  final bool isBiometricEnabled;
  final String? errorMessage;
  final bool isAuthenticating;

  const AppLocked({
    required this.mode,
    this.enteredPin = '',
    this.firstPin,
    this.isBiometricAvailable = false,
    this.isBiometricEnabled = false,
    this.errorMessage,
    this.isAuthenticating = false,
  });

  AppLocked copyWith({
    LockScreenMode? mode,
    String? enteredPin,
    String? firstPin,
    bool? isBiometricAvailable,
    bool? isBiometricEnabled,
    String? errorMessage,
    bool? isAuthenticating,
    bool clearError = false,
    bool clearFirstPin = false,
  }) {
    return AppLocked(
      mode: mode ?? this.mode,
      enteredPin: enteredPin ?? this.enteredPin,
      firstPin: clearFirstPin ? null : (firstPin ?? this.firstPin),
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
    );
  }

  @override
  List<Object?> get props => [
        mode,
        enteredPin,
        firstPin,
        isBiometricAvailable,
        isBiometricEnabled,
        errorMessage,
        isAuthenticating,
      ];
}

/// App is unlocked - allow normal access
class AppUnlocked extends AppLockState {
  final String? pin;
  const AppUnlocked({this.pin});

  @override
  List<Object?> get props => [pin];
}

/// App lock settings state (for settings screen)
class AppLockSettings extends AppLockState {
  final bool isLockEnabled;
  final bool isBiometricAvailable;
  final bool isBiometricEnabled;

  const AppLockSettings({
    required this.isLockEnabled,
    required this.isBiometricAvailable,
    required this.isBiometricEnabled,
  });

  AppLockSettings copyWith({
    bool? isLockEnabled,
    bool? isBiometricAvailable,
    bool? isBiometricEnabled,
  }) {
    return AppLockSettings(
      isLockEnabled: isLockEnabled ?? this.isLockEnabled,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
    );
  }

  @override
  List<Object?> get props => [isLockEnabled, isBiometricAvailable, isBiometricEnabled];
}

/// State when PIN is verified on setup/confirm step and requires security question & answer
class AppLockSetupSecurityRequired extends AppLockState {
  final String pin;
  const AppLockSetupSecurityRequired({required this.pin});

  @override
  List<Object?> get props => [pin];
}

/// Loading state for API operations (verify, reset, disable)
class AppLockLoading extends AppLockState {}

/// Generic success state for minor actions
class AppLockActionSuccess extends AppLockState {
  final String message;
  const AppLockActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error state for PIN-related actions (e.g. incorrect answer, bad PIN)
class AppLockActionFailure extends AppLockState {
  final String error;
  const AppLockActionFailure(this.error);

  @override
  List<Object?> get props => [error];
}
