import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/core/utils/app_settings_manager.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/widgets/liquid_glass/app_liquid_glass_switch.dart';
import 'package:expense_management/shared/widgets/sf_symbols.dart';
import 'package:expense_management/shared/widgets/screen_header.dart';
import 'package:expense_management/shared/widgets/fading_blur_layer.dart';
import 'package:expense_management/shared/widgets/app_button.dart';
import 'package:restart_app/restart_app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/core/theme/theme_cubit.dart';
import 'package:expense_management/shared/widgets/animated_toggle_bar.dart';

/// Screen for general app settings (e.g. navigation animations, theme preferences)
class GeneralSettingsScreen extends StatefulWidget {
  const GeneralSettingsScreen({super.key});

  @override
  State<GeneralSettingsScreen> createState() => _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends State<GeneralSettingsScreen> {
  bool _disableTabAnimation = false;
  bool _disableLiquidGlass = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _disableTabAnimation = AppSettingsManager.isTabAnimationDisabled();
      _disableLiquidGlass = AppSettingsManager.isLiquidGlassDisabled();
    });
  }

  Future<void> _toggleTabAnimation(bool value) async {
    await AppSettingsManager.setDisableTabAnimation(value);
    setState(() {
      _disableTabAnimation = value;
    });
  }

  Future<void> _toggleLiquidGlass(bool value) async {
    await AppSettingsManager.setDisableLiquidGlass(value);
    setState(() {
      _disableLiquidGlass = value;
    });
    if (mounted) {
      _showRestartDialog(context);
    }
  }

  void _showRestartDialog(BuildContext context) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Restart Required',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        final isDark = AppColors.isDark(context);
        final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.gray900;
        final subtextColor = isDark ? Colors.grey[400]! : AppColors.gray500;
        
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                decoration: ShapeDecoration(
                  color: bgColor,
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon circle
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                      child: const Icon(
                        Icons.restart_alt_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    AppText(
                      'Yêu cầu khởi động lại',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Message
                    AppText(
                      'Thay đổi hiệu ứng kính lỏng yêu cầu khởi động lại ứng dụng để áp dụng cấu hình đồ họa mới.',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: subtextColor,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Restart button
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: 'Khởi động lại ngay',
                        onPressed: () {
                          Restart.restartApp();
                        },
                        backgroundColor: AppColors.primary,
                        height: 48,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final bgColor = AppColors.background(context);
    final cardColor = isDark
        ? const Color(0xFF1C1C1E)
        : const Color(0xFFF7F7F9);
    final textColor = isDark ? Colors.white : AppColors.gray900;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final headerHeight = statusBarHeight + 64.0;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. Scrollable Settings Content
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, headerHeight + 16, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Settings Illustration/Icon
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF249689).withValues(alpha: 0.15),
                            AppColors.primary.withValues(alpha: 0.15),
                          ],
                        ),
                      ),
                      child: const Icon(
                        SFSymbols.gearshape_fill,
                        size: 40,
                        color: Color(0xFF249689),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: AppText(
                      'Cài đặt ứng dụng',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: AppText(
                      'Tùy chỉnh giao diện và hiệu ứng',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.gray500,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Theme Mode Selection Bento Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: ShapeDecoration(
                      color: cardColor,
                      shape: RoundedSuperellipseBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: ShapeDecoration(
                                color: Colors.amber.withValues(alpha: 0.12),
                                shape: RoundedSuperellipseBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Icon(
                                Icons.palette_rounded,
                                color: Colors.amber,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    'Giao diện ứng dụng',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                  ),
                                  const SizedBox(height: 2),
                                  AppText(
                                    'Sáng, tối hoặc tự động theo hệ thống',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.gray500,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        BlocBuilder<ThemeCubit, ThemeMode>(
                          builder: (context, themeMode) {
                            final selectedIndex = _getThemeIndex(themeMode);
                            return AnimatedToggleBar(
                              options: const ['Sáng', 'Tối', 'Hệ thống'],
                              selectedIndex: selectedIndex,
                              onChanged: (index) {
                                final mode = _getThemeModeFromIndex(index);
                                if (mode == ThemeMode.light) {
                                  context.read<ThemeCubit>().setLight();
                                } else if (mode == ThemeMode.dark) {
                                  context.read<ThemeCubit>().setDark();
                                } else {
                                  context.read<ThemeCubit>().setSystem();
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tab Transition Animation Toggle Card
                  _buildSettingCard(
                    context,
                    cardColor: cardColor,
                    textColor: textColor,
                    icon: Icons.animation_rounded,
                    iconColor: AppColors.primary,
                    title: 'Hiệu ứng chuyển trang',
                    subtitle: _disableTabAnimation
                        ? 'Đã tắt - các trang chính sẽ chuyển ngay lập tức'
                        : 'Đang bật - hiệu ứng fade-through mượt mà',
                    trailing: AppLiquidGlassSwitch(
                      value: !_disableTabAnimation,
                      onChanged: (value) => _toggleTabAnimation(!value),
                      activeColor: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Liquid Glass Effect Toggle Card
                  _buildSettingCard(
                    context,
                    cardColor: cardColor,
                    textColor: textColor,
                    icon: Icons.opacity_rounded,
                    iconColor: AppColors.cyan600,
                    title: 'Tắt hiệu ứng kính lỏng (Liquid)',
                    subtitle: _disableLiquidGlass
                        ? 'Đã tắt - sử dụng hiệu ứng blur kính mờ phẳng'
                        : 'Đang bật - hiệu ứng kính lỏng 3D khúc xạ ánh sáng',
                    trailing: AppLiquidGlassSwitch(
                      value: _disableLiquidGlass,
                      onChanged: _toggleLiquidGlass,
                      activeColor: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Settings Info Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: ShapeDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      shape: RoundedSuperellipseBorder(
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppText(
                            'Tắt các hiệu ứng chuyển trang và kính lỏng (Liquid Glass) giúp tối ưu hóa hiệu năng tối đa, giảm mức tiêu thụ pin và loại bỏ hoàn toàn độ trễ giao diện trên các thiết bị cũ.',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: isDark ? AppColors.gray300 : AppColors.gray700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Transparent Header with Gradient Blur (Pinned at top)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: Stack(
              children: [
                Positioned.fill(
                  child: const FadingBlurLayer(stops: [0.35, 1.0]),
                ),

                // Fading Background Color Layer
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          bgColor,
                          bgColor.withValues(alpha: 0.8),
                          bgColor.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),

                // Actual Header Widgets
                Positioned.fill(
                  child: Container(
                    padding: EdgeInsets.only(top: statusBarHeight),
                    alignment: Alignment.center,
                    child: ScreenHeader(
                      title: 'Cài đặt',
                      showBackButton: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getThemeIndex(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 0;
      case ThemeMode.dark:
        return 1;
      case ThemeMode.system:
        return 2;
    }
  }

  ThemeMode _getThemeModeFromIndex(int index) {
    switch (index) {
      case 0:
        return ThemeMode.light;
      case 1:
        return ThemeMode.dark;
      case 2:
      default:
        return ThemeMode.system;
    }
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required Color cardColor,
    required Color textColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: cardColor,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: ShapeDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    subtitle,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.gray500,
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
