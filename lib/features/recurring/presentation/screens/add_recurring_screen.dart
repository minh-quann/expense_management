import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/widgets/app_button.dart';
import 'package:expense_management/shared/widgets/custom_number_pad.dart';
import 'package:expense_management/shared/utils/currency_formatter.dart';
import 'package:expense_management/features/recurring/domain/entities/recurring.dart';
import 'package:expense_management/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:expense_management/features/recurring/presentation/bloc/recurring_event.dart';
import 'package:expense_management/core/utils/auth_token_manager.dart';
import 'package:expense_management/shared/widgets/app_toast.dart';
import 'package:expense_management/shared/widgets/screen_header.dart';

class AddRecurringScreen extends StatefulWidget {
  const AddRecurringScreen({super.key});

  @override
  State<AddRecurringScreen> createState() => _AddRecurringScreenState();
}

class _AddRecurringScreenState extends State<AddRecurringScreen> {
  String _amount = '0';
  final TextEditingController _noteController = TextEditingController();
  RecurringType _type = RecurringType.expense;
  RecurringFrequency _frequency = RecurringFrequency.monthly;

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

  void _saveRecurring() {
    if (_amount == '0' || _amount.isEmpty) {
      AppToast.warning(context, 'Vui lòng nhập số tiền hợp lệ');
      return;
    }

    final userId = AuthTokenManager.getUserId();
    final now = DateTime.now();
    final recurring = AppRecurring(
      id: '',
      amount: double.parse(_amount),
      type: _type,
      categoryId: 'default_category', // Placeholder until CategoryPicker is integrated here
      walletId: 'default_wallet',     // Placeholder until WalletPicker is integrated here
      note: _noteController.text.trim(),
      frequency: _frequency,
      nextOccurrenceDate: DateTime(now.year, now.month + 1, now.day),
      isActive: true,
      createdAt: now,
    );

    context.read<RecurringBloc>().add(AddRecurringEvent(userId, recurring));
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
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<RecurringType>(
                      segments: const [
                        ButtonSegment(value: RecurringType.expense, label: AppText('Chi tiền')),
                        ButtonSegment(value: RecurringType.income, label: AppText('Thu tiền')),
                      ],
                      selected: {_type},
                      onSelectionChanged: (Set<RecurringType> newSelection) {
                        setState(() => _type = newSelection.first);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
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
                          fontSize: 48, fontWeight: FontWeight.w600, color: AppColors.primary
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppText('Ghi chú', fontSize: 16, color: AppColors.textSecondary(context)),
                  TextField(
                    controller: _noteController,
                    style: TextStyle(fontSize: 16, color: AppColors.textPrimary(context)),
                    decoration: InputDecoration(
                      hintText: 'VD: Tiền nhà, Lương',
                      hintStyle: TextStyle(color: AppColors.textSecondary(context).withValues(alpha: 0.5)),
                      border: InputBorder.none,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 24),
                  AppText('Tần suất', fontSize: 16, color: AppColors.textSecondary(context)),
                  DropdownButton<RecurringFrequency>(
                    value: _frequency,
                    isExpanded: true,
                    items: RecurringFrequency.values.map((f) {
                      return DropdownMenuItem(
                        value: f,
                        child: AppText(f.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _frequency = val);
                      }
                    },
                  ),
                  const Spacer(),
                  AppButton(
                    label: 'Lưu định kỳ',
                    onPressed: _saveRecurring,
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
                      title: 'Giao dịch định kỳ',
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
