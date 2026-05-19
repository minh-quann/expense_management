import 'package:equatable/equatable.dart';
import 'package:expense_management/features/categories/domain/entities/category.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<AppCategory> expenseCategories;
  final List<AppCategory> incomeCategories;

  const CategoryLoaded({
    required this.expenseCategories,
    required this.incomeCategories,
  });

  @override
  List<Object?> get props => [expenseCategories, incomeCategories];
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoryOperationSuccess extends CategoryState {}
