import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/features/goals/domain/entities/goal.dart';

class GoalModel extends AppGoal {
  const GoalModel({
    required super.id,
    required super.name,
    required super.targetAmount,
    required super.currentAmount,
    super.icon,
    super.color,
    super.deadline,
    super.linkedWalletId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory GoalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GoalModel(
      id: doc.id,
      name: data['name'] as String,
      targetAmount: (data['targetAmount'] as num).toDouble(),
      currentAmount: (data['currentAmount'] as num).toDouble(),
      icon: data['icon'] as String?,
      color: data['color'] as String?,
      deadline: (data['deadline'] as Timestamp?)?.toDate(),
      linkedWalletId: data['linkedWalletId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'icon': icon,
      'color': color,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'linkedWalletId': linkedWalletId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory GoalModel.fromEntity(AppGoal entity) {
    return GoalModel(
      id: entity.id,
      name: entity.name,
      targetAmount: entity.targetAmount,
      currentAmount: entity.currentAmount,
      icon: entity.icon,
      color: entity.color,
      deadline: entity.deadline,
      linkedWalletId: entity.linkedWalletId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
