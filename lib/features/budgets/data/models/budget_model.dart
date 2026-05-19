import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/features/budgets/domain/entities/budget.dart';

class BudgetModel extends AppBudget {
  const BudgetModel({
    required super.id,
    super.categoryId,
    super.categoryName,
    required super.amountLimit,
    required super.period,
    required super.startDate,
    required super.endDate,
    required super.isActive,
    required super.createdAt,
  });

  factory BudgetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    BudgetPeriod period;
    final periodString = data['period'] as String?;
    if (periodString == 'WEEKLY') {
      period = BudgetPeriod.weekly;
    } else if (periodString == 'YEARLY') {
      period = BudgetPeriod.yearly;
    } else {
      period = BudgetPeriod.monthly;
    }

    return BudgetModel(
      id: doc.id,
      categoryId: data['categoryId'] as String?,
      categoryName: data['categoryName'] as String?,
      amountLimit: (data['amountLimit'] as num).toDouble(),
      period: period,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    String periodString;
    switch (period) {
      case BudgetPeriod.weekly:
        periodString = 'WEEKLY';
        break;
      case BudgetPeriod.monthly:
        periodString = 'MONTHLY';
        break;
      case BudgetPeriod.yearly:
        periodString = 'YEARLY';
        break;
    }

    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'amountLimit': amountLimit,
      'period': periodString,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory BudgetModel.fromEntity(AppBudget entity) {
    return BudgetModel(
      id: entity.id,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      amountLimit: entity.amountLimit,
      period: entity.period,
      startDate: entity.startDate,
      endDate: entity.endDate,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }
}
