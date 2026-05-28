import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/features/app_lock/data/services/app_lock_service.dart';
import 'package:expense_management/injection.dart';
import 'package:expense_management/features/app_lock/presentation/bloc/app_lock_bloc.dart';
import 'package:expense_management/features/app_lock/presentation/bloc/app_lock_event.dart';
import 'package:expense_management/features/app_lock/presentation/bloc/app_lock_state.dart';
import 'package:expense_management/features/app_lock/presentation/screens/lock_screen.dart';
import 'package:expense_management/shared/widgets/app_toast.dart';
import 'package:expense_management/shared/widgets/app_liquid_glass_switch.dart';
import 'package:expense_management/shared/widgets/sf_symbols.dart';
import 'package:expense_management/shared/widgets/screen_header.dart';

/// Settings screen for managing app lock (PIN + Biometric)
class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AppLockBloc>()..add(CheckAppLockStatus()),
      child: const _SecuritySettingsView(),
    );
  }
}

class _SecuritySettingsView extends StatefulWidget {
  const _SecuritySettingsView();

  @override
  State<_SecuritySettingsView> createState() => _SecuritySettingsViewState();
}

class _SecuritySettingsViewState extends State<_SecuritySettingsView> {
  bool _isLockEnabled = false;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final service = AppLockService();
    final lockEnabled = await service.isLockEnabled();
    final biometricAvailable = await service.isBiometricAvailable();
    final biometricEnabled = await service.isBiometricEnabled();

    if (mounted) {
      setState(() {
        _isLockEnabled = lockEnabled;
        _isBiometricAvailable = biometricAvailable;
        _isBiometricEnabled = biometricEnabled;
      });
    }
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

    return BlocListener<AppLockBloc, AppLockState>(
      listener: (context, state) {
        if (state is AppLockSettings) {
          setState(() {
            _isLockEnabled = state.isLockEnabled;
            _isBiometricAvailable = state.isBiometricAvailable;
            _isBiometricEnabled = state.isBiometricEnabled;
          });
        }
        if (state is AppLockDisabled) {
          setState(() {
            _isLockEnabled = false;
            _isBiometricEnabled = false;
          });
        }
        if (state is AppLockActionFailure) {
          AppToast.error(context, state.error);
          _loadSettings();
        }
        if (state is AppLockActionSuccess) {
          AppToast.success(context, state.message);
          _loadSettings();
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            // 1. Content
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, headerHeight + 16, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header icon
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
                              AppColors.primary.withValues(alpha: 0.15),
                              AppColors.purple500.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                        child: const Icon(
                          SFSymbols.lock_shield_fill,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: AppText(
                        'Bảo vệ ứng dụng của bạn',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: AppText(
                        'Thiết lập mã PIN và sinh trắc học',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.gray500,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // PIN Lock
                    _buildSettingCard(
                      context,
                      cardColor: cardColor,
                      textColor: textColor,
                      icon: SFSymbols.lock_fill,
                      iconColor: AppColors.primary,
                      title: 'Khóa bằng mã PIN',
                      subtitle: _isLockEnabled
                          ? 'Ứng dụng sẽ yêu cầu mã PIN khi mở'
                          : 'Tắt - không yêu cầu mã PIN',
                      trailing: const Icon(
                        SFSymbols.chevron_right,
                        color: AppColors.gray400,
                        size: 20,
                      ),
                      onTap: () {
                        if (_isLockEnabled) {
                          _showDisableVerification(context);
                        } else {
                          _showPinSetupScreen(context);
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    // Biometric Toggle
                    AnimatedOpacity(
                      opacity: _isLockEnabled ? 1.0 : 0.5,
                      duration: const Duration(milliseconds: 200),
                      child: _buildSettingCard(
                        context,
                        cardColor: cardColor,
                        textColor: textColor,
                        icon: SFSymbols.lock_shield_fill,
                        iconColor: AppColors.green600,
                        title: 'Vân tay / Face ID',
                        subtitle: _isBiometricAvailable
                            ? (_isBiometricEnabled
                                  ? 'Đang bật - mở khóa nhanh bằng sinh trắc học'
                                  : 'Tắt - chỉ sử dụng mã PIN')
                            : 'Thiết bị không hỗ trợ sinh trắc học',
                        trailing: IgnorePointer(
                          ignoring: !(_isLockEnabled && _isBiometricAvailable),
                          child: AppLiquidGlassSwitch(
                            value: _isBiometricEnabled,
                            onChanged: (value) {
                              context.read<AppLockBloc>().add(ToggleBiometric(value));
                              setState(() => _isBiometricEnabled = value);
                            },
                            activeColor: AppColors.green600,
                          ),
                        ),
                      ),
                    ),

                    if (_isLockEnabled) ...[
                      const SizedBox(height: 12),

                      // Change PIN
                      _buildSettingCard(
                        context,
                        cardColor: cardColor,
                        textColor: textColor,
                        icon: SFSymbols.lock_fill,
                        iconColor: AppColors.orange500,
                        title: 'Đổi mã PIN',
                        subtitle: 'Thay đổi mã PIN hiện tại',
                        trailing: const Icon(
                          SFSymbols.chevron_right,
                          color: AppColors.gray400,
                          size: 20,
                        ),
                        onTap: () => _showChangePinFlow(context),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Info section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: ShapeDecoration(
                        color: AppColors.blue50,
                        shape: RoundedSuperellipseBorder(
                          side: const BorderSide(color: AppColors.blue200, width: 1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.blue600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppText(
                              'Mã PIN được lưu trữ an toàn trên thiết bị của bạn. '
                              'Nếu quên mã PIN, bạn cần đăng xuất và đăng nhập lại.',
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.blue800,
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
                  // 2.1. Fading Blur Layer
                  Positioned.fill(
                    child: ShaderMask(
                      shaderCallback: (rect) {
                        return const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black, Colors.transparent],
                          stops: [0.35, 1.0],
                        ).createShader(rect);
                      },
                      blendMode: BlendMode.dstIn,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                  ),

                  // 2.2. Fading Background Color Layer
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

                  // 2.3. Actual Header Widgets
                  Positioned.fill(
                    child: Container(
                      padding: EdgeInsets.only(top: statusBarHeight),
                      alignment: Alignment.center,
                      child: ScreenHeader(
                        title: 'Bảo mật',
                        showBackButton: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  void _showPinSetupScreen(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (routeContext) => BlocProvider(
          create: (_) => getIt<AppLockBloc>()..add(EnableAppLock('')),
          child: LockScreen(
            isSetup: true,
            onSetupComplete: () {
              Navigator.of(routeContext, rootNavigator: true).pop();
              _loadSettings();
              context.read<AppLockBloc>().add(CheckAppLockStatus());
            },
          ),
        ),
      ),
    );
  }

  void _showDisableVerification(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (routeContext) => BlocProvider(
          create: (_) => getIt<AppLockBloc>()..add(CheckAppLockStatus()),
          child: LockScreen(
            title: 'Tắt khóa ứng dụng',
            subtitle: 'Nhập mã PIN hiện tại để xác nhận tắt khóa',
            onVerified: (pin) {
              Navigator.of(routeContext, rootNavigator: true).pop();
              context.read<AppLockBloc>().add(DisableAppLock(pin));
            },
          ),
        ),
      ),
    );
  }

  void _showChangePinFlow(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (routeContext) => BlocProvider(
          create: (_) => getIt<AppLockBloc>()..add(CheckAppLockStatus()),
          child: LockScreen(
            title: 'Nhập mã PIN cũ',
            subtitle: 'Nhập mã PIN hiện tại của bạn',
            onVerified: (oldPin) {
              Navigator.of(routeContext, rootNavigator: true).pop();
              _showPinSetupScreen(context);
            },
          ),
        ),
      ),
    );
  }
}
