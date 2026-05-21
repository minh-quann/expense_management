import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/widgets/app_button.dart';
import 'package:expense_management/shared/widgets/custom_number_pad.dart';
import 'package:expense_management/shared/utils/category_helper.dart';
import 'package:expense_management/shared/utils/currency_formatter.dart';
import 'package:expense_management/features/budgets/domain/entities/budget.dart';
import 'package:expense_management/features/budgets/presentation/bloc/budget_bloc.dart';
import 'package:expense_management/features/budgets/presentation/bloc/budget_event.dart';
import 'package:expense_management/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_management/features/categories/presentation/bloc/category_state.dart';
import 'package:expense_management/core/utils/auth_token_manager.dart';
import 'package:expense_management/shared/widgets/app_toast.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  String _amount = '0';
  String? _selectedCategoryId;
  String _selectedCategoryName = 'Tổng ngân sách (Tất cả)';

  void _showNumberPad() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomNumberPad(
        onNumberPressed: (number) {
          setState(() {
            if (_amount == '0' && number != '000') {
              _amount = number;
            } else if (_amount != '0') {
              _amount += number;
            }
          });
        },
        onBackspacePressed: () {
          setState(() {
            if (_amount.length > 1) {
              _amount = _amount.substring(0, _amount.length - 1);
            } else {
              _amount = '0';
            }
          });
        },
        onDonePressed: () => Navigator.pop(context),
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          padding: const EdgeInsets.all(24),
          decoration: ShapeDecoration(
            color: AppColors.isDark(context) ? AppColors.surface(context) : Colors.white,
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('Chọn danh mục', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary(context)),
              const SizedBox(height: 16),
              ListTile(
                title: AppText('Tổng ngân sách (Tất cả)', color: AppColors.textPrimary(context)),
                onTap: () {
                  setState(() {
                    _selectedCategoryId = null;
                    _selectedCategoryName = 'Tổng ngân sách (Tất cả)';
                  });
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              Expanded(
                child: BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    if (state is CategoryLoaded) {
                      final categories = state.expenseCategories;
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
                                  child: Icon(CategoryHelper.getIcon(cat.icon), color: CategoryHelper.getColor(cat.color), size: 24),
                                ),
                                title: AppText(cat.name, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary(context)),
                                trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary(context)),
                                onTap: () {
                                  setState(() {
                                    _selectedCategoryId = cat.id;
                                    _selectedCategoryName = cat.name;
                                  });
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
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveBudget() {
    if (_amount == '0' || _amount.isEmpty) {
      AppToast.warning(context, 'Vui lòng nhập số tiền ngân sách');
      return;
    }

    final userId = AuthTokenManager.getUserId();
    final now = DateTime.now();
    final budget = AppBudget(
      id: '',
      categoryId: _selectedCategoryId,
      categoryName: _selectedCategoryId == null ? null : _selectedCategoryName,
      amountLimit: double.parse(_amount),
      period: BudgetPeriod.monthly,
      startDate: DateTime(now.year, now.month, 1),
      endDate: DateTime(now.year, now.month + 1, 0),
      isActive: true,
      createdAt: now,
    );

    context.read<BudgetBloc>().add(AddBudgetEvent(userId, budget));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AppText('Thêm ngân sách', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary(context)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _showNumberPad,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText('Số tiền', fontSize: 16, color: AppColors.textSecondary(context)),
                    const SizedBox(height: 8),
                    AppText(
                      CurrencyFormatter.format(context, double.parse(_amount)),
                      fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primary
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _showCategoryPicker,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: ShapeDecoration(
                    color: AppColors.isDark(context) ? AppColors.surface(context) : Colors.white,
                    shape: RoundedSuperellipseBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText('Danh mục', fontSize: 13, color: AppColors.textSecondary(context)),
                          const SizedBox(height: 4),
                          AppText(_selectedCategoryName, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary(context)),
                        ],
                      ),
                      Icon(Icons.chevron_right, color: AppColors.textSecondary(context)),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              AppButton(
                label: 'Lưu ngân sách',
                onPressed: _saveBudget,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
