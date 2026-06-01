import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/shared/widgets/animated_toggle_bar.dart';
import 'package:expense_management/shared/widgets/transaction_item_builder.dart';
import 'package:expense_management/shared/widgets/screen_header.dart';
import 'package:expense_management/shared/widgets/fading_blur_layer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_state.dart';
import 'package:expense_management/features/transactions/domain/entities/transaction.dart';
import 'package:expense_management/core/utils/auth_token_manager.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int _selectedFilterIndex = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final userId = AuthTokenManager.getUserId();
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
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Stack(
        children: [
          // 1. Scrollable Transactions List (scrolls underneath floating header)
          Positioned.fill(
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
                  }

                  if (_searchQuery.isNotEmpty) {
                    final query = _searchQuery.toLowerCase();
                    filtered = filtered.where((t) {
                      final noteMatch = t.note?.toLowerCase().contains(query) ?? false;
                      final categoryMatch = t.categoryName?.toLowerCase().contains(query) ?? false;
                      return noteMatch || categoryMatch;
                    }).toList();
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: statusBarHeight + 180),
                        child: const AppText('Chưa có giao dịch nào'),
                      ),
                    );
                  }

                  final grouped = _groupTransactionsByDate(filtered);
                  final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: statusBarHeight + 64 + 16 + 44 + 24, // Chừa chỗ cho Header và Filters khi chưa scroll
                      bottom: 120,
                    ),
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
                      ],
                    ),
                  );
                }
                if (state is TransactionError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: statusBarHeight + 180),
                      child: AppText(state.message, color: Colors.red),
                    ),
                  );
                }
                return Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: statusBarHeight + 180),
                    child: const AppText('Lỗi tải giao dịch'),
                  ),
                );
              },
            ),
          ),

          // 2. Floating Header & Filter Panel (Placed at the top of Stack)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            // Combined height of status bar + header + filters + spacing + fading padding
            height: statusBarHeight + 64 + 16 + 44 + 16,
            child: Stack(
              children: [
                Positioned.fill(
                  child: const FadingBlurLayer(stops: [0.65, 1.0]),
                ),

                // 2.2. Fading Background Color Layer
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.background(context),
                          AppColors.background(context).withValues(alpha: 0.8),
                          AppColors.background(context).withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),

                // 2.3. Actual Widgets (Header + Filters)
                Positioned.fill(
                  child: Column(
                    children: [
                      SizedBox(height: statusBarHeight),
                      _buildHeader(context),
                      const SizedBox(height: 16),
                      _buildFilters(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildHeader(BuildContext context) {
    return ScreenHeader(
      title: AppLocalizations.of(context)!.transactions_title,
      onSearchChanged: (query) {
        setState(() {
          _searchQuery = query;
        });
      },
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
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary(context),
        ),
        const SizedBox(height: 16),
        ...items.expand((item) => [item, const SizedBox(height: 20)]),
      ],
    );
  }
}
