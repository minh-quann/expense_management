import 'package:expense_management/features/categories/domain/entities/category.dart';

abstract class CategoryRepository {
  Stream<List<AppCategory>> getCategories(String userId, String type);
  Future<void> addCategory(String userId, AppCategory category);
  Future<void> updateCategory(String userId, AppCategory category);
  Future<void> deleteCategory(String userId, String categoryId);
  Future<void> seedDefaultCategories(String userId);
}
