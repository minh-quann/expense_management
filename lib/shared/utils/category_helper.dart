import 'package:flutter/material.dart';

class CategoryHelper {
  static IconData getIcon(String iconName) {
    switch (iconName) {
      case 'restaurant': return Icons.restaurant;
      case 'directions_car': return Icons.directions_car;
      case 'home': return Icons.home;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'sports_esports': return Icons.sports_esports;
      case 'favorite': return Icons.favorite;
      case 'menu_book': return Icons.menu_book;
      case 'card_giftcard': return Icons.card_giftcard;
      case 'family_restroom': return Icons.family_restroom;
      case 'account_balance': return Icons.account_balance;
      case 'more_horiz': return Icons.more_horiz;
      case 'work': return Icons.work;
      case 'emoji_events': return Icons.emoji_events;
      case 'trending_up': return Icons.trending_up;
      case 'real_estate_agent': return Icons.real_estate_agent;
      case 'computer': return Icons.computer;
      case 'wallet': return Icons.account_balance_wallet;
      case 'credit_card': return Icons.credit_card;
      case 'savings': return Icons.savings;
      case 'money': return Icons.attach_money;
      default: return Icons.category;
    }
  }

  static Color getColor(String hexColor) {
    if (hexColor.isEmpty) return Colors.blue;
    try {
      hexColor = hexColor.toUpperCase().replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }
}
