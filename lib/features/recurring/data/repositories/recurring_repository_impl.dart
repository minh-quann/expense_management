import 'dart:async';
import 'package:expense_management/features/recurring/domain/entities/recurring.dart';
import 'package:expense_management/features/recurring/domain/repositories/recurring_repository.dart';

class RecurringRepositoryImpl implements RecurringRepository {
  final List<AppRecurring> _recurrings = [];
  final _controller = StreamController<List<AppRecurring>>.broadcast();

  RecurringRepositoryImpl([dynamic _]);

  @override
  Stream<List<AppRecurring>> getRecurrings(String userId) {
    _controller.add(List.unmodifiable(_recurrings));
    return _controller.stream;
  }

  @override
  Future<void> addRecurring(String userId, AppRecurring recurring) async {
    _recurrings.add(recurring);
    _controller.add(List.unmodifiable(_recurrings));
  }

  @override
  Future<void> updateRecurring(String userId, AppRecurring recurring) async {
    final index = _recurrings.indexWhere((r) => r.id == recurring.id);
    if (index != -1) {
      _recurrings[index] = recurring;
      _controller.add(List.unmodifiable(_recurrings));
    }
  }

  @override
  Future<void> deleteRecurring(String userId, String recurringId) async {
    _recurrings.removeWhere((r) => r.id == recurringId);
    _controller.add(List.unmodifiable(_recurrings));
  }
}
