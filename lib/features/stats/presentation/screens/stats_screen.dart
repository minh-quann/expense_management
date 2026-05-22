import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/shared/utils/currency_formatter.dart';
import 'package:expense_management/shared/widgets/animated_toggle_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:expense_management/features/stats/presentation/bloc/stats_event.dart';
import 'package:expense_management/features/stats/presentation/bloc/stats_state.dart';
import 'package:expense_management/features/stats/domain/entities/transaction_stats.dart';
import 'package:expense_management/shared/utils/category_helper.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _touchedIndex = -1;
  String _selectedType = 'EXPENSE'; // or 'INCOME'

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    context.read<StatsBloc>().add(GetStats(month: now.month, year: now.year));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = AppColors.isDark(context);
    final bgColor = isDark ? const Color(0xFF161A23) : const Color(0xFFF0F2F5);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: AppText(
          l10n.stats_title,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary(context),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<StatsBloc, StatsState>(
          builder: (context, state) {
            if (state is StatsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is StatsLoaded) {
              final stats = state.stats;
              final isExpense = _selectedType == 'EXPENSE';
              
              final double totalAmount = isExpense ? stats.totalExpense : stats.totalIncome;
              final categories = isExpense ? stats.expenseCategories : stats.incomeCategories;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeToggle(l10n),
                    const SizedBox(height: 24),
                    _buildChartSection(l10n, totalAmount, categories),
                    const SizedBox(height: 32),
                    _buildTopSpendingSection(l10n, totalAmount, categories),
                    const SizedBox(height: 100), // Space for bottom nav
                  ],
                ),
              );
            }

            if (state is StatsError) {
              return Center(
                child: AppText(
                  'Lỗi tải dữ liệu: ${state.message}',
                  color: AppColors.red500,
                ),
              );
            }

            return const Center(child: AppText('Chưa có dữ liệu thống kê'));
          },
        ),
      ),
    );
  }

  Widget _buildTypeToggle(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: AnimatedToggleBar(
        options: [
          l10n.transactions_filter_expense,
          l10n.transactions_filter_income,
        ],
        selectedIndex: _selectedType == 'EXPENSE' ? 0 : 1,
        onChanged: (index) {
          setState(() {
            _selectedType = index == 0 ? 'EXPENSE' : 'INCOME';
            _touchedIndex = -1; // Reset touched state
          });
        },
      ),
    );
  }

  final List<Color> _chartColors = [
    AppColors.red500,
    AppColors.orange500,
    AppColors.blue500,
    AppColors.purple500,
    AppColors.green500,
    AppColors.pink500,
  ];

  Widget _buildChartSection(AppLocalizations l10n, double totalAmount, List<CategoryReport> categories) {
    final isExpense = _selectedType == 'EXPENSE';
    final chartTitle = isExpense ? l10n.stats_expense_chart : l10n.stats_income_chart;
    final totalAmountStr = CurrencyFormatter.format(context, totalAmount);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: ShapeDecoration(
        color: AppColors.surface(context),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          AppText(chartTitle, fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary(context)),
          const SizedBox(height: 8),
          AppText(totalAmountStr, fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.textPrimary(context)),
          const SizedBox(height: 32),
          if (totalAmount > 0)
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: _showingSections(totalAmount, categories),
                ),
              ),
            )
          else
            const SizedBox(
              height: 220,
              child: Center(child: AppText('Chưa có dữ liệu')),
            ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _showingSections(double total, List<CategoryReport> categories) {
    List<PieChartSectionData> sections = [];
    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final value = category.totalAmount;
      final percentage = category.percentage;
      
      Color color;
      try {
        if (category.categoryColor.startsWith('#')) {
          color = Color(int.parse(category.categoryColor.replaceFirst('#', '0xFF')));
        } else if (category.categoryColor.startsWith('0x')) {
          color = Color(int.parse(category.categoryColor));
        } else {
          color = _chartColors[i % _chartColors.length];
        }
      } catch (_) {
        color = _chartColors[i % _chartColors.length];
      }
      
      sections.add(_buildSection(i, value, color, '${percentage.toStringAsFixed(1)}%'));
    }
    return sections;
  }

  PieChartSectionData _buildSection(int index, double value, Color color, String title) {
    final isTouched = index == _touchedIndex;
    final fontSize = isTouched ? 16.0 : 12.0;
    final radius = isTouched ? 50.0 : 40.0;

    return PieChartSectionData(
      color: color,
      value: value,
      title: title,
      radius: radius,
      titleStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTopSpendingSection(AppLocalizations l10n, double total, List<CategoryReport> categories) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.stats_top_spending,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
          const SizedBox(height: 16),
          if (categories.isEmpty)
            const AppText('Không có dữ liệu')
          else
            ...categories.asMap().entries.map((entry) {
              final index = entry.key;
              final cat = entry.value;
              
              Color color;
              try {
                if (cat.categoryColor.startsWith('#')) {
                  color = Color(int.parse(cat.categoryColor.replaceFirst('#', '0xFF')));
                } else if (cat.categoryColor.startsWith('0x')) {
                  color = Color(int.parse(cat.categoryColor));
                } else {
                  color = _chartColors[index % _chartColors.length];
                }
              } catch (_) {
                color = _chartColors[index % _chartColors.length];
              }

              IconData icon = CategoryHelper.getIcon(cat.categoryIcon);

              return _buildCategoryItem(
                icon,
                color,
                cat.categoryName,
                '${cat.percentage.toStringAsFixed(1)}%',
                CurrencyFormatter.format(context, cat.totalAmount),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, Color color, String name, String percentage, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: AppColors.surface(context),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(name, fontSize: 16, fontWeight: FontWeight.w500),
                const SizedBox(height: 4),
                AppText(percentage, fontSize: 13, color: AppColors.textSecondary(context)),
              ],
            ),
          ),
          AppText(amount, fontSize: 16, fontWeight: FontWeight.w600),
        ],
      ),
    );
  }
}
