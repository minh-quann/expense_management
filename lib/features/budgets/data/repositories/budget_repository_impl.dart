import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/features/budgets/domain/entities/budget.dart';
import 'package:expense_management/features/budgets/domain/repositories/budget_repository.dart';
import 'package:expense_management/features/budgets/data/models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final FirebaseFirestore _firestore;

  BudgetRepositoryImpl(this._firestore);

  @override
  Stream<List<AppBudget>> getBudgets(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map<AppBudget>((doc) => BudgetModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<void> addBudget(String userId, AppBudget budget) async {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .doc();
    final model = BudgetModel.fromEntity(budget);
    final modelWithId = BudgetModel(
      id: ref.id,
      categoryId: model.categoryId,
      categoryName: model.categoryName,
      amountLimit: model.amountLimit,
      period: model.period,
      startDate: model.startDate,
      endDate: model.endDate,
      isActive: model.isActive,
      createdAt: DateTime.now(),
    );
    await ref.set(modelWithId.toFirestore());
  }

  @override
  Future<void> updateBudget(String userId, AppBudget budget) async {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .doc(budget.id);
    final model = BudgetModel.fromEntity(budget);
    await ref.update(model.toFirestore());
  }

  @override
  Future<void> deleteBudget(String userId, String budgetId) async {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .doc(budgetId);
    await ref.update({'isActive': false});
  }
}
