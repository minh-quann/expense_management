import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/widgets/animated_toggle_bar.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/shared/utils/category_helper.dart';
import 'package:expense_management/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_management/features/categories/presentation/bloc/category_state.dart';
import 'package:expense_management/features/categories/presentation/bloc/category_event.dart';
import 'package:expense_management/features/categories/domain/entities/category.dart';
import 'package:expense_management/core/utils/auth_token_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/shared/widgets/screen_header.dart';
import 'package:expense_management/shared/widgets/fading_blur_layer.dart';
import 'package:go_router/go_router.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _selectedTypeIndex = 0; // 0: EXPENSE, 1: INCOME

  @override
  void initState() {
    super.initState();
    // Delay loading to prevent transition animation lag
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        final userId = AuthTokenManager.getUserId();
        context.read<CategoryBloc>().add(LoadCategories(userId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bgColor = AppColors.background(context);
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final headerHeight = statusBarHeight + 64.0;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. Content
          Positioned.fill(
            child: Column(
              children: [
                SizedBox(height: headerHeight),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: AnimatedToggleBar(
                    options: [
                      l10n.transactions_filter_expense,
                      l10n.transactions_filter_income,
                    ],
                    selectedIndex: _selectedTypeIndex,
                    onChanged: (index) {
                      setState(() {
                        _selectedTypeIndex = index;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      if (state is CategoryLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is CategoryLoaded) {
                        final categories = _selectedTypeIndex == 0 
                            ? state.expenseCategories 
                            : state.incomeCategories;
                            
                        if (categories.isEmpty) {
                          return const Center(child: AppText('Chưa có danh mục nào'));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            final color = CategoryHelper.getColor(cat.color);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: ShapeDecoration(
                                color: AppColors.surface(context),
                                shape: RoundedSuperellipseBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(CategoryHelper.getIcon(cat.icon), color: color, size: 24),
                                ),
                                title: AppText(cat.name, fontSize: 16, fontWeight: FontWeight.w500),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!cat.isSystem)
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                        onPressed: () => _showDeleteConfirmation(context, cat.id, cat.name),
                                      ),
                                    Icon(Icons.chevron_right, color: AppColors.textSecondary(context)),
                                  ],
                                ),
                                onTap: () async {
                                  final result = await context.push('/add_category', extra: cat);
                                  if (result != null && result is Map<String, dynamic> && context.mounted) {
                                    final userId = AuthTokenManager.getUserId();
                                    final updatedCategory = AppCategory(
                                      id: cat.id,
                                      name: result['name'] as String,
                                      icon: CategoryHelper.getIconName(result['icon'] as IconData),
                                      color: CategoryHelper.getColorHex(result['color'] as Color),
                                      type: result['type'] as String,
                                      parentId: cat.parentId,
                                      isSystem: cat.isSystem,
                                      isActive: cat.isActive,
                                      order: cat.order,
                                      createdAt: cat.createdAt,
                                    );
                                    context.read<CategoryBloc>().add(UpdateCategoryEvent(userId, updatedCategory));
                                  }
                                },
                              ),
                            );
                          },
                        );
                      }
                      return const Center(child: AppText('Lỗi tải danh mục'));
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // 2. Transparent Header with Gradient Blur (Pinned at top)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: Stack(
              children: [
                Positioned.fill(
                  child: const FadingBlurLayer(stops: [0.35, 1.0]),
                ),

                // 2.2. Fading Background Color Layer
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          bgColor,
                          bgColor.withValues(alpha: 0.8),
                          bgColor.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),

                // 2.3. Actual Header Widgets
                Positioned.fill(
                  child: Container(
                    padding: EdgeInsets.only(top: statusBarHeight),
                    alignment: Alignment.center,
                    child: ScreenHeader(
                      title: 'Danh mục',
                      showBackButton: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/add_category');
          if (result != null && result is Map<String, dynamic> && context.mounted) {
            final userId = AuthTokenManager.getUserId();
            final newCategory = AppCategory(
              id: '',
              name: result['name'] as String,
              icon: CategoryHelper.getIconName(result['icon'] as IconData),
              color: CategoryHelper.getColorHex(result['color'] as Color),
              type: result['type'] as String,
              parentId: null,
              isSystem: false,
              isActive: true,
              order: 0,
              createdAt: DateTime.now(),
            );
            context.read<CategoryBloc>().add(AddCategoryEvent(userId, newCategory));
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String categoryId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const AppText('Xóa danh mục', fontWeight: FontWeight.w600),
        content: AppText('Bạn có chắc chắn muốn xóa danh mục "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: AppText('Hủy', color: AppColors.textSecondary(context)),
          ),
          TextButton(
            onPressed: () {
              final userId = AuthTokenManager.getUserId();
              context.read<CategoryBloc>().add(DeleteCategoryEvent(userId, categoryId));
              Navigator.pop(ctx);
            },
            child: const AppText('Xóa', color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
