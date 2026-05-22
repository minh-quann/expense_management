import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/features/app_lock/data/services/app_lock_service.dart';
import 'package:expense_management/features/app_lock/presentation/bloc/app_lock_bloc.dart';
import 'package:expense_management/features/app_lock/presentation/bloc/app_lock_event.dart';
import 'package:expense_management/features/app_lock/presentation/bloc/app_lock_state.dart';
import 'package:expense_management/features/app_lock/presentation/screens/lock_screen.dart';
import 'package:expense_management/shared/widgets/app_toast.dart';

/// Settings screen for managing app lock (PIN + Biometric)
class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppLockBloc()..add(CheckAppLockStatus()),
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
    final bgColor = isDark ? const Color(0xFF000000) : Colors.white;
    final cardColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF7F7F9);
    final textColor = isDark ? Colors.white : AppColors.gray900;

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
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: AppText(
            'Bảo mật',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                    Icons.shield_outlined,
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

              // PIN Lock Toggle
              _buildSettingCard(
                context,
                cardColor: cardColor,
                textColor: textColor,
                icon: Icons.lock_outline_rounded,
                iconColor: AppColors.primary,
                title: 'Khóa bằng mã PIN',
                subtitle: _isLockEnabled
                    ? 'Ứng dụng sẽ yêu cầu mã PIN khi mở'
                    : 'Tắt - không yêu cầu mã PIN',
                trailing: Switch.adaptive(
                  value: _isLockEnabled,
                  onChanged: (value) {
                    if (value) {
                      _showPinSetupScreen(context);
                    } else {
                      _showDisableVerification(context);
                    }
                  },
                  activeTrackColor: AppColors.primary,
                ),
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
                  icon: Icons.fingerprint,
                  iconColor: AppColors.green600,
                  title: 'Vân tay / Face ID',
                  subtitle: _isBiometricAvailable
                      ? (_isBiometricEnabled
                          ? 'Đang bật - mở khóa nhanh bằng sinh trắc học'
                          : 'Tắt - chỉ sử dụng mã PIN')
                      : 'Thiết bị không hỗ trợ sinh trắc học',
                  trailing: Switch.adaptive(
                    value: _isBiometricEnabled,
                    onChanged: (_isLockEnabled && _isBiometricAvailable)
                        ? (value) {
                            context.read<AppLockBloc>().add(ToggleBiometric(value));
                            setState(() => _isBiometricEnabled = value);
                          }
                        : null,
                    activeTrackColor: AppColors.green600,
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
                  icon: Icons.dialpad_rounded,
                  iconColor: AppColors.orange500,
                  title: 'Đổi mã PIN',
                  subtitle: 'Thay đổi mã PIN hiện tại',
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.gray400,
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
                    side: const BorderSide(
                      color: AppColors.blue200,
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
          create: (_) => AppLockBloc()..add(EnableAppLock('')),
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
          create: (_) => AppLockBloc()..add(CheckAppLockStatus()),
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
          create: (_) => AppLockBloc()..add(CheckAppLockStatus()),
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
