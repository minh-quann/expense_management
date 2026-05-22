import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/widgets/app_button.dart';
import 'package:expense_management/shared/widgets/animated_toggle_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_management/shared/widgets/superellipse_input_border.dart';

import 'package:expense_management/features/categories/domain/entities/category.dart';
import 'package:expense_management/shared/utils/category_helper.dart';

class AddCategoryScreen extends StatefulWidget {
  final AppCategory? category;
  const AddCategoryScreen({super.key, this.category});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  int _selectedTypeIndex = 0; // 0: Expense, 1: Income
  
  IconData _selectedIcon = Icons.fastfood;
  Color _selectedColor = AppColors.orange500;

  final List<IconData> _availableIcons = [
    Icons.fastfood, Icons.local_cafe, Icons.directions_car, Icons.home,
    Icons.shopping_bag, Icons.health_and_safety, Icons.school, Icons.sports_esports,
    Icons.card_giftcard, Icons.pets, Icons.flight, Icons.work,
    Icons.trending_up, Icons.account_balance, Icons.attach_money, Icons.more_horiz,
  ];

  final List<Color> _availableColors = [
    AppColors.red500, AppColors.orange500, AppColors.yellow500, AppColors.green500,
    AppColors.blue500, AppColors.purple500, AppColors.pink500, AppColors.gray500,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedTypeIndex = widget.category!.type == 'EXPENSE' ? 0 : 1;
      _selectedIcon = CategoryHelper.getIcon(widget.category!.icon);
      _selectedColor = CategoryHelper.getColor(widget.category!.color);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final bgColor = isDark ? const Color(0xFF161A23) : const Color(0xFFF0F2F5);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: AppText(
          widget.category != null ? 'Chỉnh sửa danh mục' : 'Thêm danh mục',
          fontSize: 18,
          fontWeight: FontWeight.w600,
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Preview
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _selectedColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_selectedIcon, color: _selectedColor, size: 48),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Type Toggle
                    AnimatedToggleBar(
                      options: const ['Chi tiêu', 'Thu nhập'],
                      selectedIndex: _selectedTypeIndex,
                      onChanged: (index) {
                        setState(() {
                          _selectedTypeIndex = index;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Name Input
                    AppText('Tên danh mục', fontSize: 14, fontWeight: FontWeight.w500),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontFamily: 'Inter',
                      ),
                      decoration: InputDecoration(
                        hintText: 'Nhập tên danh mục...',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontFamily: 'Inter',
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.gray100,
                        border: SuperellipseInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.border(context)),
                        ),
                        enabledBorder: SuperellipseInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.border(context)),
                        ),
                        focusedBorder: SuperellipseInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Colors
                    AppText('Màu sắc', fontSize: 14, fontWeight: FontWeight.w500),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _availableColors.map((color) => _buildColorItem(color)).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Icons
                    AppText('Biểu tượng', fontSize: 14, fontWeight: FontWeight.w500),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _availableIcons.length,
                      itemBuilder: (context, index) {
                        return _buildIconItem(_availableIcons[index]);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: AppButton(
                label: 'Lưu danh mục',
                onPressed: () {
                  if (_nameController.text.trim().isEmpty) return;
                  context.pop({
                    'name': _nameController.text.trim(),
                    'type': _selectedTypeIndex == 0 ? 'EXPENSE' : 'INCOME',
                    'icon': _selectedIcon,
                    'color': _selectedColor,
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorItem(Color color) {
    final isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: AppColors.textPrimary(context), width: 2) : null,
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
      ),
    );
  }

  Widget _buildIconItem(IconData icon) {
    final isSelected = _selectedIcon == icon;
    return GestureDetector(
      onTap: () => setState(() => _selectedIcon = icon),
      child: Container(
        decoration: ShapeDecoration(
          color: isSelected ? _selectedColor.withValues(alpha: 0.1) : (AppColors.isDark(context) ? Colors.white.withValues(alpha: 0.05) : AppColors.gray100),
          shape: RoundedSuperellipseBorder(
            side: isSelected ? BorderSide(color: _selectedColor, width: 2) : const BorderSide(color: Colors.transparent, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Icon(
          icon,
          color: isSelected ? _selectedColor : AppColors.textSecondary(context),
          size: 24,
        ),
      ),
    );
  }
}
