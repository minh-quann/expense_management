import 'package:expense_management/features/categories/domain/repositories/category_repository.dart';

class SeedDefaultCategoriesUseCase {
  final CategoryRepository repository;

  SeedDefaultCategoriesUseCase(this.repository);

  Future<void> call(String userId) {
    return repository.seedDefaultCategories(userId);
  }
}
