import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/widgets/custom_number_pad.dart';
import 'package:expense_management/features/recurring/domain/entities/recurring.dart';
import 'package:expense_management/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:expense_management/features/recurring/presentation/bloc/recurring_event.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    if (_amount == '0' || _amount.isEmpty) return;

    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'test_user';
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
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AppText('Giao dịch định kỳ', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary(context)),
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
                    AppText('\$$_amount', fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primary),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveRecurring,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: const AppText('Lưu định kỳ', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
