import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/core/localization/locale_cubit.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:expense_management/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_management/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_management/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_management/features/auth/presentation/widgets/social_button.dart';
import 'package:expense_management/l10n/app_localizations.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _onGoogleLoginPressed(BuildContext context) {
    context.read<AuthBloc>().add(LoginWithGoogleEvent());
  }

  void _onFacebookLoginPressed(BuildContext context) {
    // TODO: Implement Facebook login
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.go('/');
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, authState) {
          return Stack(
            children: [
              // Full-screen gradient background
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3B5998), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // Top content area (gradient section)
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Language toggle
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16, top: 8),
                        child: IconButton(
                          onPressed: () => context.read<LocaleCubit>().toggleLanguage(),
                          tooltip: 'Change Language',
                          icon: const Icon(Icons.translate, color: Colors.white, size: 24),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    // App icon / illustration
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // App name
                    AppText(
                      l10n.login_app_name,
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),

                    const SizedBox(height: 8),

                    // Tagline
                    AppText(
                      l10n.login_enter_details,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ],
                ),
              ),

              // Bottom card that stretches to the bottom of the screen
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: screenHeight * 0.45,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppText(
                        l10n.login_welcome_back,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        l10n.login_or_sign_in_with,
                        fontSize: 14,
                        color: AppColors.textSecondary(context),
                      ),
                      const SizedBox(height: 32),

                      // Google button
                      SocialButton(
                        label: l10n.login_google,
                        icon: SvgPicture.asset('assets/icons/google-icon-logo-svgrepo-com.svg', width: 20, height: 20),
                        onPressed: authState is AuthLoading ? () {} : () => _onGoogleLoginPressed(context),
                      ),

                      const SizedBox(height: 16),

                      // Facebook button
                      SocialButton(
                        label: l10n.login_facebook,
                        icon: const FaIcon(FontAwesomeIcons.facebook, color: Color(0xFF1877F2), size: 20),
                        onPressed: authState is AuthLoading ? () {} : () => _onFacebookLoginPressed(context),
                      ),

                      const Spacer(),

                      // Loading indicator
                      if (authState is AuthLoading)
                        const CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
