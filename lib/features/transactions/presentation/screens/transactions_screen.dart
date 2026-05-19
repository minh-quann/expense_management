import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/shared/widgets/animated_toggle_bar.dart';
import 'package:expense_management/shared/widgets/transaction_item_builder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_state.dart';
import 'package:expense_management/features/transactions/domain/entities/transaction.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'test_user';
    context.read<TransactionBloc>().add(LoadTransactions(userId));
  }

  Map<DateTime, List<AppTransaction>> _groupTransactionsByDate(List<AppTransaction> transactions) {
    final Map<DateTime, List<AppTransaction>> grouped = {};
    for (var tx in transactions) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(tx);
    }
    return grouped;
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return AppLocalizations.of(context)?.transactions_today ?? 'Hôm nay';
    } else if (date == yesterday) {
      return AppLocalizations.of(context)?.transactions_yesterday ?? 'Hôm qua';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildFilters(context),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, state) {
                  if (state is TransactionLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TransactionLoaded) {
                    List<AppTransaction> filtered = state.transactions;
                    if (_selectedFilterIndex == 1) {
                      filtered = filtered.where((t) => t.type == TransactionType.expense).toList();
                    } else if (_selectedFilterIndex == 2) {
                      filtered = filtered.where((t) => t.type == TransactionType.income).toList();
                    } else if (_selectedFilterIndex == 3) {
                      filtered = filtered.where((t) => t.type == TransactionType.transfer).toList();
                    }

                    if (filtered.isEmpty) {
                      return const Center(child: AppText('Chưa có giao dịch nào'));
                    }

                    final grouped = _groupTransactionsByDate(filtered);
                    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var date in sortedDates) ...[
                            _buildDateGroup(
                              context,
                              _formatDateLabel(date),
                              grouped[date]!.map((tx) {
                                return TransactionItemBuilder.buildItem(
                                  context: context,
                                  tx: tx,
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                          ],
                          const SizedBox(height: 120),
                        ],
                      ),
                    );
                  }
                  if (state is TransactionError) {
                    return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: AppText(state.message, color: Colors.red)));
                  }
                  return const Center(child: AppText('Lỗi tải giao dịch'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 44),
          AppText(
            AppLocalizations.of(context)!.transactions_title,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.isDark(context) ? Colors.white.withValues(alpha: 0.05) : AppColors.iconBgLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.search_rounded, color: AppColors.textPrimary(context), size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: AnimatedToggleBar(
        options: [
          AppLocalizations.of(context)!.transactions_filter_all,
          AppLocalizations.of(context)!.transactions_filter_expense,
          AppLocalizations.of(context)!.transactions_filter_income,
          AppLocalizations.of(context)!.transactions_filter_transfer,
        ],
        selectedIndex: _selectedFilterIndex,
        onChanged: (index) {
          setState(() {
            _selectedFilterIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildDateGroup(BuildContext context, String dateLabel, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          dateLabel,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary(context),
        ),
        const SizedBox(height: 16),
        ...items.expand((item) => [item, const SizedBox(height: 20)]),
      ],
    );
  }
}
