import 'package:expense_management/features/recurring/domain/entities/recurring.dart';

abstract class RecurringRepository {
  Stream<List<AppRecurring>> getRecurrings(String userId);
  Future<void> addRecurring(String userId, AppRecurring recurring);
  Future<void> updateRecurring(String userId, AppRecurring recurring);
  Future<void> deleteRecurring(String userId, String recurringId);
}
