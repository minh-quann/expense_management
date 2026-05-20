import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/features/wallets/domain/entities/wallet.dart';

class WalletModel extends Wallet {
  const WalletModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.type,
    required super.balance,
    required super.currency,
    required super.icon,
    required super.color,
    required super.excludeFromTotal,
    super.isFavorite = false,
  });

  factory WalletModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WalletModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      type: WalletType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => WalletType.cash,
      ),
      balance: (data['balance'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'VND',
      icon: data['icon'] ?? '',
      color: data['color'] ?? '',
      excludeFromTotal: data['excludeFromTotal'] ?? false,
      isFavorite: data['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'type': type.name,
      'balance': balance,
      'currency': currency,
      'icon': icon,
      'color': color,
      'excludeFromTotal': excludeFromTotal,
      'isFavorite': isFavorite,
    };
  }
}
