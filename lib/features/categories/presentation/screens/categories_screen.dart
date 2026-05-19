import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/widgets/animated_toggle_bar.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _selectedTypeIndex = 0; // 0: EXPENSE, 1: INCOME
  
  final List<_CustomCategory> _customExpenseCategories = [];
  final List<_CustomCategory> _customIncomeCategories = [];

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
          'Danh mục',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary(context),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary(context), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                children: _selectedTypeIndex == 0 ? _buildExpenseCategories() : _buildIncomeCategories(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/add_category');
          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              final newCat = _CustomCategory(
                name: result['name'] as String,
                icon: result['icon'] as IconData,
                color: result['color'] as Color,
              );
              if (result['type'] == 'EXPENSE') {
                _customExpenseCategories.add(newCat);
                _selectedTypeIndex = 0;
              } else {
                _customIncomeCategories.add(newCat);
                _selectedTypeIndex = 1;
              }
            });
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  List<Widget> _buildExpenseCategories() {
    return [
      _buildCategoryGroup(
        title: 'Ăn uống',
        icon: Icons.restaurant,
        iconColor: AppColors.orange500,
        subCategories: [
          _CategoryItem('Đi chợ / Siêu thị', Icons.shopping_cart),
          _CategoryItem('Ăn ngoài', Icons.local_dining),
          _CategoryItem('Cà phê', Icons.local_cafe),
        ],
      ),
      const SizedBox(height: 16),
      _buildCategoryGroup(
        title: 'Di chuyển',
        icon: Icons.directions_car,
        iconColor: AppColors.purple500,
        subCategories: [
          _CategoryItem('Xăng dầu', Icons.local_gas_station),
          _CategoryItem('Grab / Taxi', Icons.local_taxi),
          _CategoryItem('Gửi xe', Icons.local_parking),
        ],
      ),
      const SizedBox(height: 16),
      _buildCategoryGroup(
        title: 'Nhà ở',
        icon: Icons.home,
        iconColor: AppColors.blue500,
        subCategories: [
          _CategoryItem('Tiền nhà', Icons.house),
          _CategoryItem('Điện nước', Icons.water_drop),
          _CategoryItem('Internet', Icons.wifi),
        ],
      ),
      const SizedBox(height: 16),
      if (_customExpenseCategories.isNotEmpty)
        _buildCategoryGroup(
          title: 'Khác (Tùy chỉnh)',
          icon: Icons.category,
          iconColor: AppColors.gray500,
          subCategories: _customExpenseCategories.map((e) => _CategoryItem(e.name, e.icon, customColor: e.color)).toList(),
        ),
      const SizedBox(height: 80),
    ];
  }

  List<Widget> _buildIncomeCategories() {
    return [
      _buildCategoryGroup(
        title: 'Lương',
        icon: Icons.work,
        iconColor: AppColors.green500,
        subCategories: [],
      ),
      const SizedBox(height: 16),
      _buildCategoryGroup(
        title: 'Thưởng',
        icon: Icons.card_giftcard,
        iconColor: AppColors.pink500,
        subCategories: [],
      ),
      const SizedBox(height: 16),
      _buildCategoryGroup(
        title: 'Đầu tư',
        icon: Icons.trending_up,
        iconColor: AppColors.blue500,
        subCategories: [],
      ),
      const SizedBox(height: 16),
      if (_customIncomeCategories.isNotEmpty)
        _buildCategoryGroup(
          title: 'Khác (Tùy chỉnh)',
          icon: Icons.category,
          iconColor: AppColors.gray500,
          subCategories: _customIncomeCategories.map((e) => _CategoryItem(e.name, e.icon, customColor: e.color)).toList(),
        ),
      const SizedBox(height: 80),
    ];
  }

  Widget _buildCategoryGroup({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<_CategoryItem> subCategories,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppText(title, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          if (subCategories.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 56.0, right: 16.0, bottom: 8.0),
              child: const Divider(height: 1),
            ),
            ...subCategories.map((sub) => InkWell(
              onTap: () {
                // Select category
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 56.0, right: 16.0, top: 12.0, bottom: 12.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: sub.customColor != null ? sub.customColor!.withValues(alpha: 0.1) : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(sub.icon, size: 18, color: sub.customColor ?? AppColors.textSecondary(context)),
                    ),
                    const SizedBox(width: 12),
                    AppText(sub.name, fontSize: 15, color: AppColors.textPrimary(context)),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _CategoryItem {
  final String name;
  final IconData icon;
  final Color? customColor;

  _CategoryItem(this.name, this.icon, {this.customColor});
}

class _CustomCategory {
  final String name;
  final IconData icon;
  final Color color;

  _CustomCategory({required this.name, required this.icon, required this.color});
}
