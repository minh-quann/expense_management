import 'package:expense_management/features/categories/domain/entities/category.dart';

final List<AppCategory> defaultExpenseCategories = [
  AppCategory(id: '', name: 'Ăn uống', icon: 'restaurant', color: '#F97316', type: 'EXPENSE', isSystem: true, isActive: true, order: 0, createdAt: DateTime.now()),
  AppCategory(id: '', name: 'Di chuyển', icon: 'directions_car', color: '#3B82F6', type: 'EXPENSE', isSystem: true, isActive: true, order: 1, createdAt: DateTime.now()),
  AppCategory(id: '', name: 'Nhà ở', icon: 'home', color: '#10B981', type: 'EXPENSE', isSystem: true, isActive: true, order: 2, createdAt: DateTime.now()),
  AppCategory(id: '', name: 'Mua sắm', icon: 'shopping_cart', color: '#EC4899', type: 'EXPENSE', isSystem: true, isActive: true, order: 3, createdAt: DateTime.now()),
  AppCategory(id: '', name: 'Giải trí', icon: 'sports_esports', color: '#8B5CF6', type: 'EXPENSE', isSystem: true, isActive: true, order: 4, createdAt: DateTime.now()),
  AppCategory(id: '', name: 'Sức khỏe', icon: 'favorite', color: '#EF4444', type: 'EXPENSE', isSystem: true, isActive: true, order: 5, createdAt: DateTime.now()),
  AppCategory(id: '', name: 'Học tập', icon: 'menu_book', color: '#F59E0B', type: 'EXPENSE', isSystem: true, isActive: true, order: 6, createdAt: DateTime.now()),
  AppCategory(id: '', name: 'Giao hiếu', icon: 'card_giftcard', color: '#06B6D4', type: 'EXPENSE', isSystem: true, isActive: true, order: 7, createdAt: DateTime.now()),
  AppCategory(id: '', name: 'Gia đình', icon: 'family_restroom', color: '#14B8A6', type: 'EXPENSE', isSystem: true, isActive: true, order: 8, createdAt: DateTime.now()),
  AppCategory(id: '', name: 'Tài chính', icon: 'account_balance', color: '#6366F1', type: 'EXPENSE', isSystem: true, isActive: true, order: 9, createdAt: DateTime.now()),
  AppCategory(id: '', name: 'Khác', icon: 'more_horiz', color: '#6B7280', type: 'EXPENSE', isSystem: true, isActive: true, order: 10, createdAt: DateTime.now()),
];

final List<AppCategory> defaultIncomeCategories = [
  AppCategory(id: '', name: 'Lương', icon: 'work', color: '#10B981', type: 'INCOME', isSystem: true, isActive: true, order: 0, createdAt: DateTime.now()),
  AppCategory(id: '', name: 'Thưởng', icon: 'emoji_events', color: '#F59E0B', type: 'INCOME', isSystem: true, isActive: true, order: 1, createdAt: DateTime.now()),
  AppCategory(id: '', name: 'Đầu tư', icon: 'trending_up', color: '#3B82F6', type: 'INCOME', isSystem: true, isActive: true, order: 2, createdAt: DateTime.now()),
  AppCategory(id: '', name: 'Cho thuê', icon: 'real_estate_agent', color: '#8B5CF6', type: 'INCOME', isSystem: true, isActive: true, order: 3, createdAt: DateTime.now()),
  AppCategory(id: '', name: 'Làm thêm', icon: 'computer', color: '#EC4899', type: 'INCOME', isSystem: true, isActive: true, order: 4, createdAt: DateTime.now()),
  AppCategory(id: '', name: 'Được tặng', icon: 'card_giftcard', color: '#F97316', type: 'INCOME', isSystem: true, isActive: true, order: 5, createdAt: DateTime.now()),
  AppCategory(id: '', name: 'Khác', icon: 'more_horiz', color: '#6B7280', type: 'INCOME', isSystem: true, isActive: true, order: 6, createdAt: DateTime.now()),
];
