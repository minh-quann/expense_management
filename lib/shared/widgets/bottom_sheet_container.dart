import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';

/// Reusable bottom sheet container with handle bar and title.
/// Used for category picker, wallet picker, etc.
class BottomSheetContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final double heightFactor;

  const BottomSheetContainer({
    super.key,
    required this.title,
    required this.child,
    this.heightFactor = 0.7,
  });

  /// Show as a modal bottom sheet
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    double heightFactor = 0.7,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BottomSheetContainer(
        title: title,
        heightFactor: heightFactor,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * heightFactor,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: AppColors.isDark(context)
            ? AppColors.surface(context)
            : Colors.white,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            title,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
          const SizedBox(height: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}
