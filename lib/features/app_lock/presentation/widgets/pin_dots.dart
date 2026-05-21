import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';

/// PIN dot indicator widget - shows filled/empty dots representing PIN entry progress
class PinDots extends StatelessWidget {
  final int pinLength;
  final int enteredLength;
  final bool hasError;

  const PinDots({
    super.key,
    required this.pinLength,
    required this.enteredLength,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pinLength, (index) {
        final isFilled = index < enteredLength;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: isFilled ? 18 : 16,
          height: isFilled ? 18 : 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasError
                ? AppColors.error
                : isFilled
                    ? AppColors.primary
                    : Colors.transparent,
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : isFilled
                      ? AppColors.primary
                      : AppColors.gray400,
              width: 2,
            ),
            boxShadow: isFilled && !hasError
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
