class AppGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String? icon;
  final String? color;
  final DateTime? deadline;
  final String? linkedWalletId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.icon,
    this.color,
    this.deadline,
    this.linkedWalletId,
    required this.createdAt,
    required this.updatedAt,
  });
}
