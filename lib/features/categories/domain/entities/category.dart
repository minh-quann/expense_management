class AppCategory {
  final String id;
  final String name;
  final String icon;
  final String color;
  final String type; // 'EXPENSE' or 'INCOME'
  final String? parentId;
  final bool isSystem;
  final bool isActive;
  final int order;
  final DateTime createdAt;

  const AppCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    this.parentId,
    required this.isSystem,
    required this.isActive,
    required this.order,
    required this.createdAt,
  });
}
