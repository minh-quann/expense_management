import 'package:expense_management/features/categories/domain/entities/category.dart';
import 'package:expense_management/features/categories/domain/repositories/category_repository.dart';

class AddCategoryUseCase {
  final CategoryRepository repository;

  AddCategoryUseCase(this.repository);

  Future<void> call(String userId, AppCategory category) {
    return repository.addCategory(userId, category);
  }
}
