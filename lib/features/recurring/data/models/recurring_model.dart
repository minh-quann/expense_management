import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/features/recurring/domain/entities/recurring.dart';

class RecurringModel extends AppRecurring {
  const RecurringModel({
    required super.id,
    required super.amount,
    required super.type,
    required super.categoryId,
    required super.walletId,
    super.note,
    required super.frequency,
    required super.nextOccurrenceDate,
    super.endDate,
    required super.isActive,
    required super.createdAt,
  });

  factory RecurringModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    RecurringType type = data['type'] == 'INCOME' ? RecurringType.income : RecurringType.expense;
    
    RecurringFrequency frequency;
    switch (data['frequency'] as String?) {
      case 'DAILY':
        frequency = RecurringFrequency.daily;
        break;
      case 'WEEKLY':
        frequency = RecurringFrequency.weekly;
        break;
      case 'YEARLY':
        frequency = RecurringFrequency.yearly;
        break;
      default:
        frequency = RecurringFrequency.monthly;
    }

    return RecurringModel(
      id: doc.id,
      amount: (data['amount'] as num).toDouble(),
      type: type,
      categoryId: data['categoryId'] as String,
      walletId: data['walletId'] as String,
      note: data['note'] as String?,
      frequency: frequency,
      nextOccurrenceDate: (data['nextOccurrenceDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    String frequencyStr;
    switch (frequency) {
      case RecurringFrequency.daily:
        frequencyStr = 'DAILY';
        break;
      case RecurringFrequency.weekly:
        frequencyStr = 'WEEKLY';
        break;
      case RecurringFrequency.monthly:
        frequencyStr = 'MONTHLY';
        break;
      case RecurringFrequency.yearly:
        frequencyStr = 'YEARLY';
        break;
    }

    return {
      'amount': amount,
      'type': type == RecurringType.income ? 'INCOME' : 'EXPENSE',
      'categoryId': categoryId,
      'walletId': walletId,
      'note': note,
      'frequency': frequencyStr,
      'nextOccurrenceDate': Timestamp.fromDate(nextOccurrenceDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory RecurringModel.fromEntity(AppRecurring entity) {
    return RecurringModel(
      id: entity.id,
      amount: entity.amount,
      type: entity.type,
      categoryId: entity.categoryId,
      walletId: entity.walletId,
      note: entity.note,
      frequency: entity.frequency,
      nextOccurrenceDate: entity.nextOccurrenceDate,
      endDate: entity.endDate,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }
}
