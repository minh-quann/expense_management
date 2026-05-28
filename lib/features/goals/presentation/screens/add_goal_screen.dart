import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/widgets/app_button.dart';
import 'package:expense_management/shared/widgets/custom_number_pad.dart';
import 'package:expense_management/shared/utils/currency_formatter.dart';
import 'package:expense_management/features/goals/domain/entities/goal.dart';
import 'package:expense_management/features/goals/presentation/bloc/goal_bloc.dart';
import 'package:expense_management/features/goals/presentation/bloc/goal_event.dart';
import 'package:expense_management/core/utils/auth_token_manager.dart';
import 'package:expense_management/shared/widgets/app_toast.dart';
import 'package:expense_management/shared/widgets/screen_header.dart';

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
      AppToast.warning(context, 'Vui lòng nhập số tiền mục tiêu');
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      AppToast.warning(context, 'Vui lòng nhập tên mục tiêu');
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
    final bgColor = AppColors.background(context);
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final headerHeight = statusBarHeight + 64.0;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. Content
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, headerHeight + 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('Tên mục tiêu', fontSize: 16, color: AppColors.textSecondary(context)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: TextStyle(fontSize: 20, color: AppColors.textPrimary(context), fontWeight: FontWeight.w600),
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
                          fontSize: 48, fontWeight: FontWeight.w600, color: AppColors.primary
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  AppButton(
                    label: 'Lưu mục tiêu',
                    onPressed: _saveGoal,
                  ),
                ],
              ),
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
                // 2.1. Fading Blur Layer
                Positioned.fill(
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black, Colors.transparent],
                        stops: [0.35, 1.0],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstIn,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
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
                      title: 'Thêm mục tiêu',
                      showBackButton: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
