import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_management/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_management/features/auth/presentation/bloc/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = AppColors.isDark(context);
    final bgColor = isDark ? const Color(0xFF161A23) : Colors.white;
    final surfaceColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF7F7F9);
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final greyText = isDark ? Colors.grey[400] : const Color(0xFFA0A0A0);
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Left Icon (Grid)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/profile/grid.svg',
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                        ),
                      ),
                      // Title
                      AppText(
                        l10n.profile_title,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                      // Top Right Icon (Edit)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/profile/edit.svg',
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Avatar with Edit Badge
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: surfaceColor,
                      backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                      child: user?.photoURL == null
                          ? Icon(Icons.person, size: 54, color: greyText)
                          : null,
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
                
                const SizedBox(height: 16),
                
                // Name & Email
                AppText(
                  user?.displayName ?? 'Leslie Alexander', // Default if null to match mockup
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                const SizedBox(height: 4),
                AppText(
                  user?.email ?? 'leslie@gmail.com', // Default if null to match mockup
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: greyText,
                ),
                
                const SizedBox(height: 40),
                
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
                      ),
                      _buildMenuItem(
                        context,
                        iconPath: 'assets/icons/profile/shield.svg', // Will update icons later
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
                        iconPath: 'assets/icons/profile/shield.svg',
                        iconBgColor: const Color(0xFF4CD964),
                        title: l10n.profile_security_code,
                        textColor: textColor,
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
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(14),
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

  void _showLogoutConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: AppText(l10n.profile_logout, fontSize: 20, fontWeight: FontWeight.bold),
        content: AppText(l10n.profile_logout_confirm),
        backgroundColor: AppColors.isDark(context) ? const Color(0xFF1C1C1E) : Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: AppText(l10n.profile_cancel, color: Colors.grey[600]),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(LogoutEvent());
            },
            child: AppText(l10n.profile_logout, color: const Color(0xFFFF3B30), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
