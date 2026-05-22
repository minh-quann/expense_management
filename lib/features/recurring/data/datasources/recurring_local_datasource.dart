import 'package:expense_management/features/recurring/data/models/recurring_model.dart';
import 'package:expense_management/features/recurring/domain/entities/recurring.dart';

abstract class RecurringLocalDataSource {
  Future<List<RecurringModel>> getRecurrings();
  Future<void> addRecurring(AppRecurring recurring);
  Future<void> updateRecurring(AppRecurring recurring);
  Future<void> deleteRecurring(String recurringId);
}

class RecurringLocalDataSourceImpl implements RecurringLocalDataSource {
  final List<RecurringModel> _recurrings = [];

  @override
  Future<List<RecurringModel>> getRecurrings() async {
    return List.from(_recurrings);
  }

  @override
  Future<void> addRecurring(AppRecurring recurring) async {
    _recurrings.add(RecurringModel.fromEntity(recurring));
  }

  @override
  Future<void> updateRecurring(AppRecurring recurring) async {
    final index = _recurrings.indexWhere((r) => r.id == recurring.id);
    if (index != -1) {
      _recurrings[index] = RecurringModel.fromEntity(recurring);
    }
  }

  @override
  Future<void> deleteRecurring(String recurringId) async {
    _recurrings.removeWhere((r) => r.id == recurringId);
  }
}
