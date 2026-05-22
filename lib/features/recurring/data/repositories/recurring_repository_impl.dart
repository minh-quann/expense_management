import 'dart:async';
import 'package:expense_management/features/recurring/data/datasources/recurring_local_datasource.dart';
import 'package:expense_management/features/recurring/domain/entities/recurring.dart';
import 'package:expense_management/features/recurring/domain/repositories/recurring_repository.dart';

class RecurringRepositoryImpl implements RecurringRepository {
  final RecurringLocalDataSource _localDataSource;
  final _controller = StreamController<List<AppRecurring>>.broadcast();

  // Accept optional parameter for backwards compatibility
  RecurringRepositoryImpl([dynamic _]) : _localDataSource = RecurringLocalDataSourceImpl();

  RecurringRepositoryImpl.withDataSource(this._localDataSource);

  Future<void> _fetchAndEmit() async {
    try {
      final list = await _localDataSource.getRecurrings();
      _controller.add(list);
    } catch (e) {
      _controller.addError(e);
    }
  }

  @override
  Stream<List<AppRecurring>> getRecurrings(String userId) {
    _fetchAndEmit();
    return _controller.stream;
  }

  @override
  Future<void> addRecurring(String userId, AppRecurring recurring) async {
    await _localDataSource.addRecurring(recurring);
    await _fetchAndEmit();
  }

  @override
  Future<void> updateRecurring(String userId, AppRecurring recurring) async {
    await _localDataSource.updateRecurring(recurring);
    await _fetchAndEmit();
  }

  @override
  Future<void> deleteRecurring(String userId, String recurringId) async {
    await _localDataSource.deleteRecurring(recurringId);
    await _fetchAndEmit();
  }
}
