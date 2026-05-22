import 'package:expense_management/features/categories/domain/entities/category.dart';
import 'package:expense_management/features/categories/domain/repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository repository;

  GetCategoriesUseCase(this.repository);

  Stream<List<AppCategory>> call(String userId, String type) {
    return repository.getCategories(userId, type);
  }
}
