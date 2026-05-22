import 'package:expense_management/core/network/api_client.dart';
import 'package:expense_management/features/categories/data/models/category_model.dart';
import 'package:expense_management/features/categories/domain/entities/category.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories(String type);
  Future<void> addCategory(AppCategory category);
  Future<void> updateCategory(AppCategory category);
  Future<void> deleteCategory(String categoryId);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiClient _apiClient;

  CategoryRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<List<CategoryModel>> getCategories(String type) async {
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
    return list;
  }

  @override
  Future<void> addCategory(AppCategory category) async {
    await _apiClient.dio.post('/categories', data: {
      'name': category.name,
      'icon': category.icon,
      'color': category.color,
      'type': category.type,
      'parent_id': category.parentId,
      'is_active': category.isActive,
      'order': category.order,
    });
  }

  @override
  Future<void> updateCategory(AppCategory category) async {
    await _apiClient.dio.put('/categories/${category.id}', data: {
      'name': category.name,
      'icon': category.icon,
      'color': category.color,
      'type': category.type,
      'parent_id': category.parentId,
      'is_active': category.isActive,
      'order': category.order,
    });
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await _apiClient.dio.delete('/categories/$categoryId');
  }
}
