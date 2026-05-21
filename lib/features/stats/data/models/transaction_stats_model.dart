import 'package:expense_management/features/stats/domain/entities/transaction_stats.dart';

class CategoryReportModel extends CategoryReport {
  const CategoryReportModel({
    required super.categoryId,
    required super.categoryName,
    required super.categoryIcon,
    required super.categoryColor,
    required super.totalAmount,
    required super.percentage,
  });

  factory CategoryReportModel.fromJson(Map<String, dynamic> json) {
    return CategoryReportModel(
      categoryId: json['category_id'] ?? '',
      categoryName: json['category_name'] ?? '',
      categoryIcon: json['category_icon'] ?? '',
      categoryColor: json['category_color'] ?? '',
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      percentage: (json['percentage'] ?? 0.0).toDouble(),
    );
  }
}

class TransactionStatsModel extends TransactionStats {
  const TransactionStatsModel({
    required super.totalIncome,
    required super.totalExpense,
    required super.netBalance,
    required super.expenseCategories,
    required super.incomeCategories,
  });

  factory TransactionStatsModel.fromJson(Map<String, dynamic> json) {
    final expenseCats = (json['expense_categories'] as List? ?? [])
        .map((e) => CategoryReportModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final incomeCats = (json['income_categories'] as List? ?? [])
        .map((e) => CategoryReportModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return TransactionStatsModel(
      totalIncome: (json['total_income'] ?? 0.0).toDouble(),
      totalExpense: (json['total_expense'] ?? 0.0).toDouble(),
      netBalance: (json['net_balance'] ?? 0.0).toDouble(),
      expenseCategories: expenseCats,
      incomeCategories: incomeCats,
    );
  }
}
