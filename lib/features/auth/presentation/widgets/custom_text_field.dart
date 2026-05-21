import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/widgets/superellipse_input_border.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.isPassword = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          fontSize: 12,
          color: AppColors.textSecondary(context),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 16,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: SuperellipseInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.textSecondary(context).withValues(alpha: 0.2)),
            ),
            enabledBorder: SuperellipseInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.textSecondary(context).withValues(alpha: 0.2)),
            ),
            focusedBorder: SuperellipseInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            suffixIcon: isPassword
                ? Icon(Icons.remove_red_eye_outlined, color: AppColors.textSecondary(context))
                : null,
          ),
        ),
      ],
    );
  }
}
