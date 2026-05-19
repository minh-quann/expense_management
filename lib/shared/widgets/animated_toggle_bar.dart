import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';


class AnimatedToggleBar extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const AnimatedToggleBar({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox();

    return Container(
      height: 52, 
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.isDark(context) ? Colors.white.withValues(alpha: 0.05) : AppColors.gray100,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border(context), width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final double minItemWidth = 110.0;
          double itemWidth = width / options.length;
          
          bool isScrollable = false;
          if (itemWidth < minItemWidth) {
            itemWidth = minItemWidth;
            isScrollable = true;
          }
          
          final contentWidth = itemWidth * options.length;

          Widget content = SizedBox(
            width: contentWidth,
            child: Stack(
              children: [
                // Sliding background pill
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  left: selectedIndex * itemWidth,
                  top: 0,
                  bottom: 0,
                  width: itemWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.isDark(context) ? AppColors.surface(context) : Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: AppColors.border(context).withValues(alpha: 0.5), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                  ),
                ),
                // Options
                Row(
                  children: List.generate(options.length, (index) {
                    final isSelected = selectedIndex == index;
                    return GestureDetector(
                      onTap: () => onChanged(index),
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: itemWidth,
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected 
                                ? AppColors.textPrimary(context) 
                                : AppColors.textSecondary(context),
                            ),
                            child: Text(
                              options[index],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );

          if (isScrollable) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: content,
            );
          }
          return content;
        },
      ),
    );
  }
}
