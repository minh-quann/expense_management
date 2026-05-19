import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'app_text.dart';

class CustomNumberPad extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback onDonePressed;

  const CustomNumberPad({
    super.key,
    required this.onNumberPressed,
    required this.onBackspacePressed,
    required this.onDonePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.isDark(context) ? AppColors.surface(context) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildButton(context, '1'),
              _buildButton(context, '2'),
              _buildButton(context, '3'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildButton(context, '4'),
              _buildButton(context, '5'),
              _buildButton(context, '6'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildButton(context, '7'),
              _buildButton(context, '8'),
              _buildButton(context, '9'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildButton(context, '000'),
              _buildButton(context, '0'),
              _buildIconButton(context, Icons.backspace_outlined, onBackspacePressed),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onDonePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: const AppText(
                'Xong',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text) {
    return GestureDetector(
      onTap: () => onNumberPressed(text),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: MediaQuery.of(context).size.width / 3 - 32,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.isDark(context) ? Colors.white.withValues(alpha: 0.05) : AppColors.gray50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: AppText(
          text,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary(context),
        ),
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: MediaQuery.of(context).size.width / 3 - 32,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.isDark(context) ? Colors.white.withValues(alpha: 0.05) : AppColors.gray50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: AppColors.textPrimary(context), size: 28),
      ),
    );
  }
}
