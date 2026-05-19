import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/features/categories/domain/entities/category.dart';
import 'package:expense_management/features/categories/domain/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository;
  StreamSubscription? _expenseSubscription;
  StreamSubscription? _incomeSubscription;

  List<AppCategory> _currentExpenses = [];
  List<AppCategory> _currentIncomes = [];

  CategoryBloc({required this.repository}) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategoryEvent>(_onAddCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
    on<_CategoriesUpdated>((event, emit) => emit(CategoryLoaded(
      expenseCategories: _currentExpenses,
      incomeCategories: _currentIncomes,
    )));
    on<_CategoryError>((event, emit) => emit(CategoryError(event.error)));
  }

  void _onLoadCategories(LoadCategories event, Emitter<CategoryState> emit) {
    emit(CategoryLoading());

    _expenseSubscription?.cancel();
    _incomeSubscription?.cancel();

    bool hasSeeded = false;

    _expenseSubscription = repository.getCategories(event.userId, 'EXPENSE').listen(
      (categories) async {
        _currentExpenses = categories;
        if (categories.isEmpty && !hasSeeded) {
          hasSeeded = true;
          await repository.seedDefaultCategories(event.userId);
        }
        if (!isClosed) {
          add(const _CategoriesUpdated());
        }
      },
      onError: (error) {
        if (!isClosed) {
          add(_CategoryError(error.toString()));
        }
      },
    );

    _incomeSubscription = repository.getCategories(event.userId, 'INCOME').listen(
      (categories) {
        _currentIncomes = categories;
        if (!isClosed) {
          add(const _CategoriesUpdated());
        }
      },
      onError: (error) {
        if (!isClosed) {
          add(_CategoryError(error.toString()));
        }
      },
    );
  }

  void _onAddCategory(AddCategoryEvent event, Emitter<CategoryState> emit) async {
    try {
      await repository.addCategory(event.userId, event.category);
    } catch (e) {
      emit(CategoryError('Lỗi thêm danh mục: $e'));
    }
  }

  void _onUpdateCategory(UpdateCategoryEvent event, Emitter<CategoryState> emit) async {
    try {
      await repository.updateCategory(event.userId, event.category);
    } catch (e) {
      emit(CategoryError('Lỗi cập nhật danh mục: $e'));
    }
  }

  void _onDeleteCategory(DeleteCategoryEvent event, Emitter<CategoryState> emit) async {
    try {
      await repository.deleteCategory(event.userId, event.categoryId);
    } catch (e) {
      emit(CategoryError('Lỗi xoá danh mục: $e'));
    }
  }

  @override
  Future<void> close() {
    _expenseSubscription?.cancel();
    _incomeSubscription?.cancel();
    return super.close();
  }
}

class _CategoriesUpdated extends CategoryEvent {
  const _CategoriesUpdated();
}

class _CategoryError extends CategoryEvent {
  final String error;
  const _CategoryError(this.error);
}
