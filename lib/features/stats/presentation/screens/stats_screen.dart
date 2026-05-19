import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/shared/widgets/animated_toggle_bar.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _touchedIndex = -1;
  String _selectedType = 'EXPENSE'; // or 'INCOME'

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
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeToggle(l10n),
              const SizedBox(height: 24),
              _buildChartSection(l10n, isDark),
              const SizedBox(height: 32),
              _buildTopSpendingSection(l10n, isDark),
              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
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
          });
        },
      ),
    );
  }

  Widget _buildChartSection(AppLocalizations l10n, bool isDark) {
    final isExpense = _selectedType == 'EXPENSE';
    final chartTitle = isExpense ? l10n.stats_expense_chart : l10n.stats_income_chart;
    final totalAmount = isExpense ? '₫12,500,000' : '₫35,000,000';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          AppText(chartTitle, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary(context)),
          const SizedBox(height: 8),
          AppText(totalAmount, fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary(context)),
          const SizedBox(height: 32),
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
                sections: _showingSections(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _showingSections() {
    final isExpense = _selectedType == 'EXPENSE';
    // Dummy Data
    if (isExpense) {
      return [
        _buildSection(0, 40, AppColors.red500, '40%', 'Ăn uống'),
        _buildSection(1, 25, AppColors.orange500, '25%', 'Nhà ở'),
        _buildSection(2, 20, AppColors.blue500, '20%', 'Di chuyển'),
        _buildSection(3, 15, AppColors.purple500, '15%', 'Giải trí'),
      ];
    } else {
      return [
        _buildSection(0, 80, AppColors.green500, '80%', 'Lương'),
        _buildSection(1, 20, AppColors.blue500, '20%', 'Đầu tư'),
      ];
    }
  }

  PieChartSectionData _buildSection(int index, double value, Color color, String title, String badge) {
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
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTopSpendingSection(AppLocalizations l10n, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.stats_top_spending,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
          const SizedBox(height: 16),
          if (_selectedType == 'EXPENSE') ...[
            _buildCategoryItem(Icons.restaurant, AppColors.orange500, 'Ăn uống', '40%', '₫5,000,000'),
            _buildCategoryItem(Icons.home, AppColors.blue500, 'Nhà ở', '25%', '₫3,125,000'),
            _buildCategoryItem(Icons.directions_car, AppColors.purple500, 'Di chuyển', '20%', '₫2,500,000'),
          ] else ...[
            _buildCategoryItem(Icons.work, AppColors.green500, 'Lương', '80%', '₫28,000,000'),
            _buildCategoryItem(Icons.trending_up, AppColors.blue500, 'Đầu tư', '20%', '₫7,000,000'),
          ]
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, Color color, String name, String percentage, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(context), width: 1),
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
                AppText(name, fontSize: 16, fontWeight: FontWeight.w600),
                const SizedBox(height: 4),
                AppText(percentage, fontSize: 13, color: AppColors.textSecondary(context)),
              ],
            ),
          ),
          AppText(amount, fontSize: 16, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }
}
