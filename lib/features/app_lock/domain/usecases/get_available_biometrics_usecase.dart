import 'package:local_auth/local_auth.dart';
import 'package:expense_management/features/app_lock/domain/repositories/app_lock_repository.dart';

/// Use case to retrieve a list of available biometrics on the device.
class GetAvailableBiometricsUseCase {
  final AppLockRepository _repository;

  const GetAvailableBiometricsUseCase(this._repository);

  Future<List<BiometricType>> call() {
    return _repository.getAvailableBiometrics();
  }
}
