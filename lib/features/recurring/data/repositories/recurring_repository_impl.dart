import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/features/recurring/domain/entities/recurring.dart';
import 'package:expense_management/features/recurring/domain/repositories/recurring_repository.dart';
import 'package:expense_management/features/recurring/data/models/recurring_model.dart';

class RecurringRepositoryImpl implements RecurringRepository {
  final FirebaseFirestore _firestore;

  RecurringRepositoryImpl(this._firestore);

  @override
  Stream<List<AppRecurring>> getRecurrings(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('recurringTemplates')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map<AppRecurring>((doc) => RecurringModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<void> addRecurring(String userId, AppRecurring recurring) async {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('recurringTemplates')
        .doc();
    final model = RecurringModel.fromEntity(recurring);
    final modelWithId = RecurringModel(
      id: ref.id,
      amount: model.amount,
      type: model.type,
      categoryId: model.categoryId,
      walletId: model.walletId,
      note: model.note,
      frequency: model.frequency,
      nextOccurrenceDate: model.nextOccurrenceDate,
      endDate: model.endDate,
      isActive: model.isActive,
      createdAt: DateTime.now(),
    );
    await ref.set(modelWithId.toFirestore());
  }

  @override
  Future<void> updateRecurring(String userId, AppRecurring recurring) async {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('recurringTemplates')
        .doc(recurring.id);
    final model = RecurringModel.fromEntity(recurring);
    await ref.update(model.toFirestore());
  }

  @override
  Future<void> deleteRecurring(String userId, String recurringId) async {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('recurringTemplates')
        .doc(recurringId);
    await ref.update({'isActive': false});
  }
}
