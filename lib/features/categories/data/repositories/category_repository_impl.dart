import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/features/categories/domain/entities/category.dart';
import 'package:expense_management/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_management/features/categories/data/models/category_model.dart';
import 'package:expense_management/features/categories/data/datasources/default_categories.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepositoryImpl(this._firestore);

  @override
  Stream<List<AppCategory>> getCategories(String userId, String type) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .where('type', isEqualTo: type)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map<AppCategory>((doc) => CategoryModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<void> addCategory(String userId, AppCategory category) async {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc();
    final model = CategoryModel.fromEntity(category);
    final modelWithId = CategoryModel(
      id: ref.id,
      name: model.name,
      icon: model.icon,
      color: model.color,
      type: model.type,
      parentId: model.parentId,
      isSystem: model.isSystem,
      isActive: model.isActive,
      order: model.order,
      createdAt: DateTime.now(),
    );
    await ref.set(modelWithId.toFirestore());
  }

  @override
  Future<void> updateCategory(String userId, AppCategory category) async {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc(category.id);
    final model = CategoryModel.fromEntity(category);
    await ref.update(model.toFirestore());
  }

  @override
  Future<void> deleteCategory(String userId, String categoryId) async {
    // Only soft delete if it's system? The requirement says system categories cannot be deleted.
    // We handle that in UI/Bloc. For repository, we just delete or soft-delete.
    // Let's do a soft delete (isActive = false) for all deletions to preserve transaction history links.
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc(categoryId);
    await ref.update({'isActive': false});
  }

  @override
  Future<void> seedDefaultCategories(String userId) async {
    final batch = _firestore.batch();
    final categoriesRef = _firestore.collection('users').doc(userId).collection('categories');

    for (final cat in defaultExpenseCategories) {
      final docRef = categoriesRef.doc();
      final model = CategoryModel.fromEntity(cat).copyWith(id: docRef.id);
      batch.set(docRef, model.toFirestore());
    }

    for (final cat in defaultIncomeCategories) {
      final docRef = categoriesRef.doc();
      final model = CategoryModel.fromEntity(cat).copyWith(id: docRef.id);
      batch.set(docRef, model.toFirestore());
    }

    await batch.commit();
  }
}
