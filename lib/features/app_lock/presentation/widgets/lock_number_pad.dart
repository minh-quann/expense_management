import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';

/// Custom number pad for PIN entry with biometric button support
class LockNumberPad extends StatelessWidget {
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback? onBiometricPressed;
  final bool showBiometric;

  const LockNumberPad({
    super.key,
    required this.onDigitPressed,
    required this.onDeletePressed,
    this.onBiometricPressed,
    this.showBiometric = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(context, ['1', '2', '3'], isDark),
        const SizedBox(height: 16),
        _buildRow(context, ['4', '5', '6'], isDark),
        const SizedBox(height: 16),
        _buildRow(context, ['7', '8', '9'], isDark),
        const SizedBox(height: 16),
        _buildBottomRow(context, isDark),
      ],
    );
  }

  Widget _buildRow(BuildContext context, List<String> digits, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((digit) => _buildDigitButton(context, digit, isDark)).toList(),
    );
  }

  Widget _buildBottomRow(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Biometric or empty space
        if (showBiometric)
          _buildIconButton(
            context,
            icon: Icons.fingerprint,
            onTap: onBiometricPressed,
            isDark: isDark,
          )
        else
          const SizedBox(width: 72, height: 72),

        // 0 button
        _buildDigitButton(context, '0', isDark),

        // Delete button
        _buildIconButton(
          context,
          icon: Icons.backspace_outlined,
          onTap: onDeletePressed,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildDigitButton(BuildContext context, String digit, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onDigitPressed(digit);
        },
        borderRadius: BorderRadius.circular(36),
        splashColor: AppColors.primary.withValues(alpha: 0.15),
        highlightColor: AppColors.primary.withValues(alpha: 0.08),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
          ),
          alignment: Alignment.center,
          child: AppText(
            digit,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.gray900,
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    VoidCallback? onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(36),
        splashColor: AppColors.primary.withValues(alpha: 0.15),
        child: SizedBox(
          width: 72,
          height: 72,
          child: Center(
            child: Icon(
              icon,
              size: icon == Icons.fingerprint ? 36 : 28,
              color: icon == Icons.fingerprint
                  ? AppColors.primary
                  : (isDark ? Colors.white70 : AppColors.gray600),
            ),
          ),
        ),
      ),
    );
  }
}
