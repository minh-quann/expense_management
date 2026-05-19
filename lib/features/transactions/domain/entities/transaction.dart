enum TransactionType { expense, income, transfer }

class AppTransaction {
  final String id;
  final double amount;
  final TransactionType type;
  
  final String? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  
  final String walletId;
  final String? walletName;
  
  final String? toWalletId;
  final String? toWalletName;
  
  final DateTime date;
  final String? note;
  final String? imageUrl;
  final String? recurringId;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppTransaction({
    required this.id,
    required this.amount,
    required this.type,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    required this.walletId,
    this.walletName,
    this.toWalletId,
    this.toWalletName,
    required this.date,
    this.note,
    this.imageUrl,
    this.recurringId,
    required this.createdAt,
    required this.updatedAt,
  });
}
