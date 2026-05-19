enum BudgetPeriod { weekly, monthly, yearly }

class AppBudget {
  final String id;
  final String? categoryId; // null = ngân sách tổng
  final String? categoryName;
  final double amountLimit;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;

  const AppBudget({
    required this.id,
    this.categoryId,
    this.categoryName,
    required this.amountLimit,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.createdAt,
  });
}
