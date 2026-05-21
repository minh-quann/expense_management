class CategoryReport {
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final double totalAmount;
  final double percentage;

  const CategoryReport({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.totalAmount,
    required this.percentage,
  });
}

class TransactionStats {
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final List<CategoryReport> expenseCategories;
  final List<CategoryReport> incomeCategories;

  const TransactionStats({
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
    required this.expenseCategories,
    required this.incomeCategories,
  });
}
