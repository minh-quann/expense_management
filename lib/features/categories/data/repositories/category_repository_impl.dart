import 'dart:async';
import 'package:expense_management/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:expense_management/features/categories/domain/entities/category.dart';
import 'package:expense_management/features/categories/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;
  final _categoriesController = StreamController<List<AppCategory>>.broadcast();

  // Accept optional firestore parameter to maintain backwards compatibility
  CategoryRepositoryImpl([dynamic _]) : _remoteDataSource = CategoryRemoteDataSourceImpl();

  CategoryRepositoryImpl.withDataSource(this._remoteDataSource);

  Future<void> _fetchAndEmit(String userId, String type) async {
    try {
      final list = await _remoteDataSource.getCategories(type);
      _categoriesController.add(list);
    } catch (e) {
      _categoriesController.addError(e);
    }
  }

  @override
  Stream<List<AppCategory>> getCategories(String userId, String type) {
    _fetchAndEmit(userId, type);
    return _categoriesController.stream;
  }

  @override
  Future<void> addCategory(String userId, AppCategory category) async {
    await _remoteDataSource.addCategory(category);
    await _fetchAndEmit(userId, category.type);
  }

  @override
  Future<void> updateCategory(String userId, AppCategory category) async {
    await _remoteDataSource.updateCategory(category);
    await _fetchAndEmit(userId, category.type);
  }

  @override
  Future<void> deleteCategory(String userId, String categoryId) async {
    await _remoteDataSource.deleteCategory(categoryId);
    await _fetchAndEmit(userId, 'EXPENSE');
    await _fetchAndEmit(userId, 'INCOME');
  }

  @override
  Future<void> seedDefaultCategories(String userId) async {
    // Already handled automatically in backend during registration / google login.
    return;
  }
}
