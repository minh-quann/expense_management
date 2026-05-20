import 'dart:async';
import 'package:expense_management/core/network/api_client.dart';
import 'package:expense_management/features/categories/domain/entities/category.dart';
import 'package:expense_management/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_management/features/categories/data/models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final ApiClient _apiClient = ApiClient();
  final _categoriesController = StreamController<List<AppCategory>>.broadcast();

  // Accept optional firestore parameter to maintain backwards compatibility during migration
  CategoryRepositoryImpl([dynamic _]);

  // Helper method to fetch from backend and update stream
  Future<void> _fetchAndEmit(String userId, String type) async {
    try {
      final response = await _apiClient.dio.get('/categories', queryParameters: {'type': type});
      final list = (response.data as List).map((json) {
        return CategoryModel(
          id: json['id'],
          name: json['name'],
          icon: json['icon'],
          color: json['color'],
          type: json['type'],
          parentId: json['parent_id'],
          isSystem: json['is_system'] ?? false,
          isActive: json['is_active'] ?? true,
          order: json['order'] ?? 0,
          createdAt: json['created_at'] != null 
              ? DateTime.parse(json['created_at']) 
              : DateTime.now(),
        );
      }).toList();
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
    await _apiClient.dio.post('/categories', data: {
      'name': category.name,
      'icon': category.icon,
      'color': category.color,
      'type': category.type,
      'parent_id': category.parentId,
      'is_active': category.isActive,
      'order': category.order,
    });
    await _fetchAndEmit(userId, category.type);
  }

  @override
  Future<void> updateCategory(String userId, AppCategory category) async {
    await _apiClient.dio.put('/categories/${category.id}', data: {
      'name': category.name,
      'icon': category.icon,
      'color': category.color,
      'type': category.type,
      'parent_id': category.parentId,
      'is_active': category.isActive,
      'order': category.order,
    });
    await _fetchAndEmit(userId, category.type);
  }

  @override
  Future<void> deleteCategory(String userId, String categoryId) async {
    // Need to know the category type to emit the correct list afterwards.
    // We can fetch details or just fetch for both types or keep type in context.
    // Deleting/hiding is usually followed by a screen refresh or load, but we can call a general load or emit.
    await _apiClient.dio.delete('/categories/$categoryId');
    // Re-fetch standard categories for the user (we'll query both or let the screen re-trigger getCategories stream)
    await _fetchAndEmit(userId, 'EXPENSE');
    await _fetchAndEmit(userId, 'INCOME');
  }

  @override
  Future<void> seedDefaultCategories(String userId) async {
    // Already handled automatically in backend during registration / google login.
    return;
  }
}
