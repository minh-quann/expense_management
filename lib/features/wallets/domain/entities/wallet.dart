enum WalletType {
  cash,
  bank,
  credit,
  eWallet,
}

class Wallet {
  final String id;
  final String userId;
  final String name;
  final WalletType type;
  final double balance;
  final String currency;
  final String icon;
  final String color;
  final bool excludeFromTotal;
  final bool isFavorite;

  const Wallet({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    required this.icon,
    required this.color,
    required this.excludeFromTotal,
    this.isFavorite = false,
  });
}
