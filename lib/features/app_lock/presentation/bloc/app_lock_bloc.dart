import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/features/app_lock/domain/repositories/app_lock_repository.dart';
import 'package:expense_management/features/app_lock/domain/usecases/save_pin_usecase.dart';
import 'package:expense_management/features/app_lock/domain/usecases/verify_pin_usecase.dart';
import 'package:expense_management/features/app_lock/domain/usecases/remove_pin_usecase.dart';
import 'package:expense_management/features/app_lock/domain/usecases/reset_pin_usecase.dart';
import 'package:expense_management/features/app_lock/domain/usecases/is_lock_enabled_usecase.dart';
import 'package:expense_management/features/app_lock/domain/usecases/is_biometric_enabled_usecase.dart';
import 'package:expense_management/features/app_lock/domain/usecases/set_biometric_enabled_usecase.dart';
import 'package:expense_management/features/app_lock/domain/usecases/is_biometric_available_usecase.dart';
import 'package:expense_management/features/app_lock/domain/usecases/authenticate_with_biometrics_usecase.dart';
import 'package:expense_management/features/app_lock/presentation/bloc/app_lock_event.dart';
import 'package:expense_management/features/app_lock/presentation/bloc/app_lock_state.dart';

/// BLoC managing app lock logic: PIN verification, biometric auth, and lock state.
class AppLockBloc extends Bloc<AppLockEvent, AppLockState> {
  final IsLockEnabledUseCase _isLockEnabledUseCase;
  final IsBiometricAvailableUseCase _isBiometricAvailableUseCase;
  final IsBiometricEnabledUseCase _isBiometricEnabledUseCase;
  final VerifyPinUseCase _verifyPinUseCase;
  final AuthenticateWithBiometricsUseCase _authenticateWithBiometricsUseCase;
  final RemovePinUseCase _removePinUseCase;
  final SetBiometricEnabledUseCase _setBiometricEnabledUseCase;
  final SavePinUseCase _savePinUseCase;
  final ResetPinUseCase _resetPinUseCase;

  static const int pinLength = 4;

  AppLockBloc({
    required AppLockRepository repository,
    IsLockEnabledUseCase? isLockEnabledUseCase,
    IsBiometricAvailableUseCase? isBiometricAvailableUseCase,
    IsBiometricEnabledUseCase? isBiometricEnabledUseCase,
    VerifyPinUseCase? verifyPinUseCase,
    AuthenticateWithBiometricsUseCase? authenticateWithBiometricsUseCase,
    RemovePinUseCase? removePinUseCase,
    SetBiometricEnabledUseCase? setBiometricEnabledUseCase,
    SavePinUseCase? savePinUseCase,
    ResetPinUseCase? resetPinUseCase,
  })  : _isLockEnabledUseCase = isLockEnabledUseCase ?? IsLockEnabledUseCase(repository),
        _isBiometricAvailableUseCase = isBiometricAvailableUseCase ?? IsBiometricAvailableUseCase(repository),
        _isBiometricEnabledUseCase = isBiometricEnabledUseCase ?? IsBiometricEnabledUseCase(repository),
        _verifyPinUseCase = verifyPinUseCase ?? VerifyPinUseCase(repository),
        _authenticateWithBiometricsUseCase = authenticateWithBiometricsUseCase ?? AuthenticateWithBiometricsUseCase(repository),
        _removePinUseCase = removePinUseCase ?? RemovePinUseCase(repository),
        _setBiometricEnabledUseCase = setBiometricEnabledUseCase ?? SetBiometricEnabledUseCase(repository),
        _savePinUseCase = savePinUseCase ?? SavePinUseCase(repository),
        _resetPinUseCase = resetPinUseCase ?? ResetPinUseCase(repository),
        super(AppLockInitial()) {
    on<CheckAppLockStatus>(_onCheckStatus);
    on<EnterPinDigit>(_onEnterDigit);
    on<DeletePinDigit>(_onDeleteDigit);
    on<ClearPin>(_onClearPin);
    on<AuthenticateWithBiometrics>(_onBiometricAuth);
    on<EnableAppLock>(_onEnableAppLock);
    on<DisableAppLock>(_onDisableAppLock);
    on<ToggleBiometric>(_onToggleBiometric);
    on<UnlockApp>(_onUnlockApp);
    on<LockApp>(_onLockApp);
    on<SavePinWithSecurity>(_onSavePinWithSecurity);
    on<ResetPinWithSecurity>(_onResetPinWithSecurity);
  }

  Future<void> _onCheckStatus(
    CheckAppLockStatus event,
    Emitter<AppLockState> emit,
  ) async {
    final isEnabled = await _isLockEnabledUseCase();
    if (!isEnabled) {
      emit(AppLockDisabled());
      return;
    }

    final biometricAvailable = await _isBiometricAvailableUseCase();
    final biometricEnabled = await _isBiometricEnabledUseCase();

    emit(AppLocked(
      mode: LockScreenMode.unlock,
      isBiometricAvailable: biometricAvailable,
      isBiometricEnabled: biometricEnabled,
    ));

    // Auto-trigger biometric if enabled
    if (biometricAvailable && biometricEnabled) {
      add(AuthenticateWithBiometrics());
    }
  }

  Future<void> _onEnterDigit(
    EnterPinDigit event,
    Emitter<AppLockState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AppLocked) return;

    final newPin = currentState.enteredPin + event.digit;
    if (newPin.length > pinLength) return;

    emit(currentState.copyWith(enteredPin: newPin, clearError: true));

    // When PIN is complete
    if (newPin.length == pinLength) {
      await Future.delayed(const Duration(milliseconds: 150));

      switch (currentState.mode) {
        case LockScreenMode.unlock:
          final isCorrect = await _verifyPinUseCase(newPin);
          if (isCorrect) {
            emit(AppUnlocked(pin: newPin));
          } else {
            emit(currentState.copyWith(
              enteredPin: '',
              errorMessage: 'Mã PIN không đúng. Vui lòng thử lại.',
            ));
          }
          break;

        case LockScreenMode.setup:
          // Move to confirm step
          emit(currentState.copyWith(
            mode: LockScreenMode.confirm,
            enteredPin: '',
            firstPin: newPin,
          ));
          break;

        case LockScreenMode.confirm:
          if (newPin == currentState.firstPin) {
            emit(AppLockSetupSecurityRequired(pin: newPin));
          } else {
            emit(currentState.copyWith(
              mode: LockScreenMode.setup,
              enteredPin: '',
              errorMessage: 'Mã PIN không khớp. Vui lòng nhập lại.',
              clearFirstPin: true,
            ));
          }
          break;
      }
    }
  }

  void _onDeleteDigit(
    DeletePinDigit event,
    Emitter<AppLockState> emit,
  ) {
    final currentState = state;
    if (currentState is! AppLocked) return;
    if (currentState.enteredPin.isEmpty) return;

    emit(currentState.copyWith(
      enteredPin: currentState.enteredPin.substring(
        0,
        currentState.enteredPin.length - 1,
      ),
      clearError: true,
    ));
  }

  void _onClearPin(
    ClearPin event,
    Emitter<AppLockState> emit,
  ) {
    final currentState = state;
    if (currentState is! AppLocked) return;

    emit(currentState.copyWith(enteredPin: '', clearError: true));
  }

  Future<void> _onBiometricAuth(
    AuthenticateWithBiometrics event,
    Emitter<AppLockState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AppLocked) return;

    emit(currentState.copyWith(isAuthenticating: true));

    final success = await _authenticateWithBiometricsUseCase();
    if (success) {
      emit(AppUnlocked());
    } else {
      emit(currentState.copyWith(isAuthenticating: false));
    }
  }

  Future<void> _onEnableAppLock(
    EnableAppLock event,
    Emitter<AppLockState> emit,
  ) async {
    // Show setup screen for new PIN
    emit(AppLocked(
      mode: LockScreenMode.setup,
      isBiometricAvailable: await _isBiometricAvailableUseCase(),
      isBiometricEnabled: false,
    ));
  }

  Future<void> _onDisableAppLock(
    DisableAppLock event,
    Emitter<AppLockState> emit,
  ) async {
    emit(AppLockLoading());
    try {
      await _removePinUseCase(event.pin);
      emit(const AppLockSettings(
        isLockEnabled: false,
        isBiometricAvailable: false,
        isBiometricEnabled: false,
      ));
    } catch (e) {
      emit(AppLockActionFailure(e.toString()));
    }
  }

  Future<void> _onToggleBiometric(
    ToggleBiometric event,
    Emitter<AppLockState> emit,
  ) async {
    await _setBiometricEnabledUseCase(event.enabled);

    final currentState = state;
    if (currentState is AppLockSettings) {
      emit(currentState.copyWith(isBiometricEnabled: event.enabled));
    }
  }

  void _onUnlockApp(
    UnlockApp event,
    Emitter<AppLockState> emit,
  ) {
    emit(AppUnlocked());
  }

  Future<void> _onLockApp(
    LockApp event,
    Emitter<AppLockState> emit,
  ) async {
    final isEnabled = await _isLockEnabledUseCase();
    if (!isEnabled) return;

    final biometricAvailable = await _isBiometricAvailableUseCase();
    final biometricEnabled = await _isBiometricEnabledUseCase();

    emit(AppLocked(
      mode: LockScreenMode.unlock,
      isBiometricAvailable: biometricAvailable,
      isBiometricEnabled: biometricEnabled,
    ));
  }

  Future<void> _onSavePinWithSecurity(
    SavePinWithSecurity event,
    Emitter<AppLockState> emit,
  ) async {
    emit(AppLockLoading());
    try {
      await _savePinUseCase(
        event.pin,
        question: event.question,
        answer: event.answer,
      );
      emit(AppLockSettings(
        isLockEnabled: true,
        isBiometricAvailable: await _isBiometricAvailableUseCase(),
        isBiometricEnabled: await _isBiometricEnabledUseCase(),
      ));
    } catch (e) {
      emit(AppLockActionFailure(e.toString()));
    }
  }

  Future<void> _onResetPinWithSecurity(
    ResetPinWithSecurity event,
    Emitter<AppLockState> emit,
  ) async {
    emit(AppLockLoading());
    try {
      await _resetPinUseCase(event.answer, event.newPin);
      emit(const AppLockActionSuccess('Khôi phục mã PIN thành công'));
      emit(AppUnlocked());
    } catch (e) {
      emit(AppLockActionFailure('Khôi phục mã PIN thất bại. Vui lòng kiểm tra lại câu trả lời.'));
    }
  }
}
