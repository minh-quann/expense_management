import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/core/network/api_client.dart';
import 'package:expense_management/shared/widgets/screen_header.dart';
import 'package:expense_management/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_management/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_management/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_management/features/settings/data/repositories/profile_repository.dart';
import 'package:expense_management/features/settings/presentation/bloc/profile_bloc.dart';
import 'package:expense_management/features/settings/presentation/bloc/profile_event.dart';
import 'package:expense_management/features/settings/presentation/bloc/profile_state.dart';
import 'package:expense_management/features/settings/presentation/screens/edit_profile_screen.dart';
import 'package:expense_management/features/app_lock/data/services/app_lock_service.dart';
import 'package:expense_management/features/app_lock/presentation/screens/lock_screen.dart';
import 'package:expense_management/features/app_lock/presentation/bloc/app_lock_bloc.dart';
import 'package:expense_management/features/app_lock/presentation/bloc/app_lock_event.dart';
import 'package:expense_management/shared/widgets/app_toast.dart';
import 'package:expense_management/shared/widgets/app_confirm_modal.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (context) => ProfileBloc(ProfileRepository())..add(FetchProfileEvent()),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  String _getFullPhotoUrl(String photoUrl) {
    if (photoUrl.isEmpty) return '';
    if (photoUrl.startsWith('http')) return photoUrl;
    final baseUrl = ApiClient().dio.options.baseUrl;
    final host = baseUrl.replaceAll('/api/v1', '');
    return '$host$photoUrl';
  }

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image != null && context.mounted) {
      context.read<ProfileBloc>().add(UploadAvatarEvent(localFilePath: image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final bgColor = AppColors.background(context);
    final surfaceColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF7F7F9);
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final greyText = isDark ? Colors.grey[400] : const Color(0xFFA0A0A0);
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          // Reset app lock state on logout so it doesn't display overlay on login screen
          context.read<AppLockBloc>().add(CheckAppLockStatus());
          context.go('/login');
          // Show toast after navigation — pass null since ProfileScreen context is disposed
          AppToast.success(null, 'Đăng xuất thành công!');
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading && state is! ProfileLoaded) {
                return const Center(child: CircularProgressIndicator());
              }

              // Retrieve profile details
              final profile = (state is ProfileLoaded) ? state.profile : null;
              final displayName = profile?.displayName ?? '';
              final email = profile?.email ?? '';
              final photoUrl = profile?.photoUrl ?? '';
              final currency = profile?.currencyCode ?? 'VND';

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Custom App Bar
                    ScreenHeader(
                      title: l10n.profile_title,
                      leading: ScreenHeader.circleButton(
                        context: context,
                        child: SvgPicture.asset(
                          'assets/icons/profile/grid.svg',
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                        ),
                      ),
                      trailing: ScreenHeader.circleButton(
                        context: context,
                        onTap: () {
                          if (profile != null) {
                            Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(
                                builder: (ctx) => BlocProvider.value(
                                  value: context.read<ProfileBloc>(),
                                  child: EditProfileScreen(profile: profile),
                                ),
                              ),
                            );
                          }
                        },
                        child: SvgPicture.asset(
                          'assets/icons/profile/edit.svg',
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Avatar with Edit Badge
                    GestureDetector(
                      onTap: () => _pickAndUploadImage(context),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 4),
                            ),
                            child: CircleAvatar(
                              radius: 54,
                              backgroundColor: surfaceColor,
                              backgroundImage: photoUrl.isNotEmpty
                                  ? NetworkImage(_getFullPhotoUrl(photoUrl))
                                  : null,
                              child: photoUrl.isEmpty
                                  ? Icon(Icons.person, size: 54, color: greyText)
                                  : null,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9E5FF),
                              shape: BoxShape.circle,
                              border: Border.all(color: bgColor, width: 3),
                            ),
                            child: SvgPicture.asset(
                              'assets/icons/profile/edit.svg',
                              width: 14,
                              height: 14,
                              colorFilter: const ColorFilter.mode(Color(0xFF5A45FE), BlendMode.srcIn),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Name
                    AppText(
                      displayName.isNotEmpty ? displayName : 'Tải thông tin...',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    const SizedBox(height: 4),
                    // Email
                    AppText(
                      email.isNotEmpty ? email : '...',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: greyText,
                    ),

                    if (currency.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: ShapeDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: RoundedSuperellipseBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: AppText(
                          'Đồng tiền: $currency',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 32),
                    
                    // Menu List
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            context,
                            iconPath: 'assets/icons/profile/user.svg',
                            iconBgColor: const Color(0xFF5A45FE),
                            title: l10n.profile_account_info,
                            textColor: textColor,
                            onTap: () {
                              if (profile != null) {
                                Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(
                                    builder: (ctx) => BlocProvider.value(
                                      value: context.read<ProfileBloc>(),
                                      child: EditProfileScreen(profile: profile),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          _buildMenuItem(
                            context,
                            iconPath: 'assets/icons/profile/user.svg',
                            iconBgColor: AppColors.cyan600,
                            title: 'Quản lý ví (Wallets)',
                            textColor: textColor,
                            onTap: () => context.push('/wallets'),
                          ),
                          _buildMenuItem(
                            context,
                            iconPath: 'assets/icons/profile/shield.svg',
                            iconBgColor: AppColors.orange500,
                            title: 'Ngân sách (Budgets)',
                            textColor: textColor,
                            onTap: () => context.push('/budgets'),
                          ),
                          _buildMenuItem(
                            context,
                            iconPath: 'assets/icons/profile/shield.svg',
                            iconBgColor: AppColors.pink500,
                            title: 'Mục tiêu tiết kiệm (Goals)',
                            textColor: textColor,
                            onTap: () => context.push('/goals'),
                          ),
                          _buildMenuItem(
                            context,
                            iconPath: 'assets/icons/profile/shield.svg',
                            iconBgColor: AppColors.blue500,
                            title: 'Giao dịch định kỳ',
                            textColor: textColor,
                            onTap: () => context.push('/recurring'),
                          ),
                          _buildMenuItem(
                            context,
                            iconPath: 'assets/icons/profile/settings.svg',
                            iconBgColor: AppColors.purple500,
                            title: 'Quản lý danh mục',
                            textColor: textColor,
                            onTap: () => context.push('/categories'),
                          ),
                          _buildMenuItem(
                            context,
                            iconPath: 'assets/icons/profile/shield.svg',
                            iconBgColor: const Color(0xFF4CD964),
                            title: l10n.profile_security_code,
                            textColor: textColor,
                            onTap: () => context.push('/security'),
                          ),
                          _buildMenuItem(
                            context,
                            iconPath: 'assets/icons/profile/lock.svg',
                            iconBgColor: const Color(0xFF344356),
                            title: l10n.profile_privacy_policy,
                            textColor: textColor,
                          ),
                          _buildMenuItem(
                            context,
                            iconPath: 'assets/icons/profile/settings.svg',
                            iconBgColor: const Color(0xFF249689),
                            title: l10n.profile_settings,
                            textColor: textColor,
                          ),
                          _buildMenuItem(
                            context,
                            iconPath: 'assets/icons/profile/logout.svg',
                            iconBgColor: const Color(0xFFFF3B30),
                            title: l10n.profile_logout,
                            textColor: textColor,
                            onTap: () => _showLogoutConfirmation(context),
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 100), // Extra space for floating bottom nav
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String iconPath,
    required Color iconBgColor,
    required String title,
    required Color textColor,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 24.0),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 48,
              height: 48,
              decoration: ShapeDecoration(
                color: iconBgColor,
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Title
            Expanded(
              child: AppText(
                title,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await AppConfirmModal.show(
      context: context,
      icon: Icons.logout_rounded,
      title: l10n.profile_logout,
      message: l10n.profile_logout_confirm,
      cancelLabel: l10n.profile_cancel,
      confirmLabel: l10n.profile_logout,
      isDestructive: true,
    );

    if (!confirmed || !context.mounted) return;

    final appLockService = AppLockService();
    final isPinEnabled = await appLockService.isLockEnabled();

    if (isPinEnabled && context.mounted) {
      // Open LockScreen with local bloc provider to verify PIN
      final verified = await Navigator.of(context, rootNavigator: true).push<bool>(
        MaterialPageRoute(
          builder: (ctx2) => BlocProvider<AppLockBloc>(
            create: (context) => AppLockBloc()..add(LockApp()),
            child: LockScreen(
              title: 'Xác nhận mã PIN',
              subtitle: 'Nhập mã PIN của bạn để đăng xuất',
              onVerified: (pin) {
                Navigator.pop(ctx2, true);
              },
            ),
          ),
        ),
      );

      if (verified == true && context.mounted) {
        context.read<AuthBloc>().add(LogoutEvent());
      }
    } else {
      if (context.mounted) {
        context.read<AuthBloc>().add(LogoutEvent());
      }
    }
  }
}
