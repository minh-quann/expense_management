import 'package:equatable/equatable.dart';
import 'package:expense_management/features/categories/domain/entities/category.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {
  final String userId;

  const LoadCategories(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddCategoryEvent extends CategoryEvent {
  final String userId;
  final AppCategory category;

  const AddCategoryEvent(this.userId, this.category);

  @override
  List<Object?> get props => [userId, category];
}

class UpdateCategoryEvent extends CategoryEvent {
  final String userId;
  final AppCategory category;

  const UpdateCategoryEvent(this.userId, this.category);

  @override
  List<Object?> get props => [userId, category];
}

class DeleteCategoryEvent extends CategoryEvent {
  final String userId;
  final String categoryId;

  const DeleteCategoryEvent(this.userId, this.categoryId);

  @override
  List<Object?> get props => [userId, categoryId];
}
