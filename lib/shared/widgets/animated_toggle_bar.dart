import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_liquid_glass.dart';
import 'package:expense_management/shared/widgets/app_text.dart';

class AnimatedToggleBar extends StatefulWidget {
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
  State<AnimatedToggleBar> createState() => _AnimatedToggleBarState();
}

class _AnimatedToggleBarState extends State<AnimatedToggleBar> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollToSelected(animate: false);
  }

  @override
  void didUpdateWidget(covariant AnimatedToggleBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _scrollToSelected(animate: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected({required bool animate}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      final viewportWidth = _scrollController.position.viewportDimension;
      final maxScroll = _scrollController.position.maxScrollExtent;
      
      if (maxScroll <= 0) return;

      final contentWidth = viewportWidth + maxScroll;
      final itemWidth = contentWidth / widget.options.length;

      double target = (widget.selectedIndex + 0.5) * itemWidth - viewportWidth / 2;
      target = target.clamp(0.0, maxScroll);

      if (animate) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.options.isEmpty) return const SizedBox();

    final isDark = AppColors.isDark(context);

    return SizedBox(
      height: 52,
      child: AppLiquidGlassIndicator(
        selectedIndex: widget.selectedIndex,
        count: widget.options.length,
        isDark: isDark,
        onChanged: widget.onChanged,
        borderRadius: 100,
        padding: const EdgeInsets.all(2),
        child: ClipRSuperellipse(
          borderRadius: BorderRadius.circular(98), // Inner clip to keep pill inside the 2px border
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final double minItemWidth = 110.0;
              double itemWidth = width / widget.options.length;
              
              bool isScrollable = false;
              if (itemWidth < minItemWidth) {
                itemWidth = minItemWidth;
                isScrollable = true;
              }
              
              final contentWidth = itemWidth * widget.options.length;
     
              Widget content = SizedBox(
                width: contentWidth,
                child: Row(
                  children: List.generate(widget.options.length, (index) {
                    final isSelected = widget.selectedIndex == index;
                    return GestureDetector(
                      onTap: () => widget.onChanged(index),
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: itemWidth,
                        child: Center(
                          child: AppText(
                            widget.options[index],
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w500,
                            color: isSelected 
                              ? AppColors.primary 
                              : AppColors.textSecondary(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
     
              if (isScrollable) {
                return SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: content,
                );
              }
              return content;
            },
          ),
        ),
      ),
    );
  }
}
