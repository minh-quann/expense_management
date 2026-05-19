import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/features/goals/domain/entities/goal.dart';
import 'package:expense_management/features/goals/domain/repositories/goal_repository.dart';
import 'package:expense_management/features/goals/data/models/goal_model.dart';

class GoalRepositoryImpl implements GoalRepository {
  final FirebaseFirestore _firestore;

  GoalRepositoryImpl(this._firestore);

  @override
  Stream<List<AppGoal>> getGoals(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('savingGoals')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map<AppGoal>((doc) => GoalModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<void> addGoal(String userId, AppGoal goal) async {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('savingGoals')
        .doc();
    final model = GoalModel.fromEntity(goal);
    final modelWithId = GoalModel(
      id: ref.id,
      name: model.name,
      targetAmount: model.targetAmount,
      currentAmount: model.currentAmount,
      icon: model.icon,
      color: model.color,
      deadline: model.deadline,
      linkedWalletId: model.linkedWalletId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await ref.set(modelWithId.toFirestore());
  }

  @override
  Future<void> updateGoal(String userId, AppGoal goal) async {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('savingGoals')
        .doc(goal.id);
    final model = GoalModel.fromEntity(goal);
    await ref.update(model.toFirestore());
  }

  @override
  Future<void> deleteGoal(String userId, String goalId) async {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('savingGoals')
        .doc(goalId);
    await ref.delete();
  }

  @override
  Future<void> addFundsToGoal(String userId, String goalId, double amount) async {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('savingGoals')
        .doc(goalId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) throw Exception("Goal does not exist!");
      
      final currentAmount = (snapshot.data()!['currentAmount'] as num).toDouble();
      transaction.update(ref, {
        'currentAmount': currentAmount + amount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
