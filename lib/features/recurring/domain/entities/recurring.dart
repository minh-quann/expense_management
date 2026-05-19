enum RecurringFrequency { daily, weekly, monthly, yearly }
enum RecurringType { expense, income }

class AppRecurring {
  final String id;
  final double amount;
  final RecurringType type;
  final String categoryId;
  final String walletId;
  final String? note;
  final RecurringFrequency frequency;
  final DateTime nextOccurrenceDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;

  const AppRecurring({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.walletId,
    this.note,
    required this.frequency,
    required this.nextOccurrenceDate,
    this.endDate,
    required this.isActive,
    required this.createdAt,
  });
}
