import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/widgets/superellipse_input_border.dart';

class AppTextField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final FormFieldValidator<String>? validator;

  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final isEffectivelyDisabled = !enabled || readOnly;

    final field = TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      enabled: enabled,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      minLines: minLines,
      validator: validator,
      style: TextStyle(
        fontSize: 16,
        color: isEffectivelyDisabled
            ? AppColors.textSecondary(context).withValues(alpha: 0.5)
            : AppColors.textPrimary(context),
        fontFamily: 'Inter',
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 16,
          color: AppColors.textSecondary(context).withValues(alpha: 0.5),
          fontFamily: 'Inter',
        ),
        filled: true,
        fillColor: isEffectivelyDisabled
            ? (isDark ? const Color(0xFF1C1C1E) : const Color(0xFFE5E5EA))
            : (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7)),
        border: SuperellipseInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(
            color: isEffectivelyDisabled
                ? AppColors.border(context).withValues(alpha: 0.5)
                : AppColors.border(context),
          ),
        ),
        enabledBorder: SuperellipseInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(
            color: isEffectivelyDisabled
                ? AppColors.border(context).withValues(alpha: 0.5)
                : AppColors.border(context),
          ),
        ),
        focusedBorder: SuperellipseInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        disabledBorder: SuperellipseInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(
            color: AppColors.border(context).withValues(alpha: 0.5),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
      ),
    );

    if (label != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            label!,
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 8),
          field,
        ],
      );
    }

    return field;
  }
}
