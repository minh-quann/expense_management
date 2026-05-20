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

  static String getIconName(IconData icon) {
    if (icon == Icons.restaurant || icon == Icons.fastfood || icon == Icons.local_cafe) return 'restaurant';
    if (icon == Icons.directions_car) return 'directions_car';
    if (icon == Icons.home) return 'home';
    if (icon == Icons.shopping_cart || icon == Icons.shopping_bag) return 'shopping_cart';
    if (icon == Icons.sports_esports) return 'sports_esports';
    if (icon == Icons.favorite || icon == Icons.health_and_safety) return 'favorite';
    if (icon == Icons.menu_book || icon == Icons.school) return 'menu_book';
    if (icon == Icons.card_giftcard) return 'card_giftcard';
    if (icon == Icons.family_restroom || icon == Icons.pets) return 'family_restroom';
    if (icon == Icons.account_balance) return 'account_balance';
    if (icon == Icons.more_horiz) return 'more_horiz';
    if (icon == Icons.work) return 'work';
    if (icon == Icons.emoji_events || icon == Icons.flight) return 'emoji_events';
    if (icon == Icons.trending_up) return 'trending_up';
    if (icon == Icons.real_estate_agent) return 'real_estate_agent';
    if (icon == Icons.computer) return 'computer';
    if (icon == Icons.account_balance_wallet) return 'wallet';
    if (icon == Icons.credit_card) return 'credit_card';
    if (icon == Icons.savings) return 'savings';
    if (icon == Icons.attach_money) return 'money';
    return 'more_horiz';
  }

  static String getColorHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}
