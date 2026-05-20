import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/utils/category_helper.dart';
import 'package:expense_management/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_management/features/categories/presentation/bloc/category_state.dart';
import 'package:expense_management/features/categories/domain/entities/category.dart';

/// A bottom sheet content widget to select a category.
class CategoryPickerSheet extends StatelessWidget {
  final String transactionType;
  final ValueChanged<AppCategory> onCategorySelected;

  const CategoryPickerSheet({
    super.key,
    required this.transactionType,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CategoryLoaded) {
          final categories = transactionType == 'INCOME'
              ? state.incomeCategories
              : state.expenseCategories;
          if (categories.isEmpty) {
            return Center(
              child: AppText(
                'Chưa có danh mục nào',
                color: AppColors.textSecondary(context),
              ),
            );
          }
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CategoryHelper.getColor(cat.color).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CategoryHelper.getIcon(cat.icon),
                        color: CategoryHelper.getColor(cat.color),
                        size: 24,
                      ),
                    ),
                    title: AppText(
                      cat.name,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                    trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary(context)),
                    onTap: () {
                      onCategorySelected(cat);
                      Navigator.pop(context);
                    },
                  ),
                  if (index < categories.length - 1) 
                    Divider(height: 1, indent: 64, color: AppColors.border(context)),
                ],
              );
            },
          );
        }
        return Center(
          child: AppText(
            'Lỗi tải danh mục',
            color: AppColors.textSecondary(context),
          ),
        );
      },
    );
  }
}
