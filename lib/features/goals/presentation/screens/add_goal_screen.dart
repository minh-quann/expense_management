import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/widgets/custom_number_pad.dart';
import 'package:expense_management/shared/utils/currency_formatter.dart';
import 'package:expense_management/features/goals/domain/entities/goal.dart';
import 'package:expense_management/features/goals/presentation/bloc/goal_bloc.dart';
import 'package:expense_management/features/goals/presentation/bloc/goal_event.dart';
import 'package:expense_management/core/utils/auth_token_manager.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  String _amount = '0';
  final TextEditingController _nameController = TextEditingController();

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

  void _saveGoal() {
    if (_amount == '0' || _amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập số tiền mục tiêu')));
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên mục tiêu')));
      return;
    }

    final userId = AuthTokenManager.getUserId();
    final now = DateTime.now();
    final goal = AppGoal(
      id: '',
      name: _nameController.text.trim(),
      targetAmount: double.parse(_amount),
      currentAmount: 0,
      createdAt: now,
      updatedAt: now,
    );

    context.read<GoalBloc>().add(AddGoalEvent(userId, goal));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AppText('Thêm mục tiêu', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary(context)),
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
              AppText('Tên mục tiêu', fontSize: 16, color: AppColors.textSecondary(context)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: TextStyle(fontSize: 20, color: AppColors.textPrimary(context), fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'VD: Mua iPhone 16',
                  hintStyle: TextStyle(color: AppColors.textSecondary(context).withValues(alpha: 0.5)),
                  border: InputBorder.none,
                ),
              ),
              const Divider(),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _showNumberPad,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText('Số tiền mục tiêu', fontSize: 16, color: AppColors.textSecondary(context)),
                    const SizedBox(height: 8),
                    AppText(
                      CurrencyFormatter.format(context, double.parse(_amount)),
                      fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primary
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: const AppText('Lưu mục tiêu', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
