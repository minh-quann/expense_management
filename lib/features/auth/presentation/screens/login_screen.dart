import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter/services.dart';

import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/core/localization/locale_cubit.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/widgets/app_button.dart';
import 'package:expense_management/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_management/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_management/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_management/shared/widgets/app_toast.dart';
import 'package:expense_management/features/auth/presentation/widgets/social_button.dart';
import 'package:expense_management/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:expense_management/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isRegistering = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _onGoogleLoginPressed(BuildContext context) {
    context.read<AuthBloc>().add(LoginWithGoogleEvent());
  }

  void _onSubmitPressed(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      if (_isRegistering) {
        context.read<AuthBloc>().add(RegisterWithEmailEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              displayName: _displayNameController.text.trim(),
            ));
      } else {
        context.read<AuthBloc>().add(LoginWithEmailEvent(
              _emailController.text.trim(),
              _passwordController.text,
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = AppColors.isDark(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: AppColors.surface(context),
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
      backgroundColor: AppColors.surface(context),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            AppToast.success(context, 'Đăng nhập thành công!');
            context.go('/');
          } else if (state is AuthFailure) {
            AppToast.error(context, state.message);
          }
        },
        builder: (context, authState) {
          final bottomPadding = MediaQuery.of(context).padding.bottom;
          return Stack(
            children: [
              // Gradient background - exclude bottom nav bar area
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: bottomPadding,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3B5998), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              // Scrollable Layout to prevent keyboard overflow issues
              SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
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

                          SizedBox(height: screenHeight * 0.02),

                          // App logo
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // App name
                          AppText(
                            l10n.login_app_name,
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),

                          const SizedBox(height: 4),

                          // Subtitle
                          AppText(
                            _isRegistering ? 'Đăng ký tài khoản mới' : l10n.login_enter_details,
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          color: AppColors.surface(context),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppText(
                                _isRegistering ? 'Đăng Ký' : l10n.login_welcome_back,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),

                              if (_isRegistering) ...[
                                AuthTextField(
                                  controller: _displayNameController,
                                  labelText: 'Tên hiển thị',
                                  hintText: 'Nhập tên của bạn',
                                  prefixIcon: Icons.person_outline,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Vui lòng nhập tên';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],

                              AuthTextField(
                                controller: _emailController,
                                labelText: 'Email',
                                hintText: 'example@email.com',
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Vui lòng nhập email';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                    return 'Email không hợp lệ';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              AuthTextField(
                                controller: _passwordController,
                                labelText: 'Mật khẩu',
                                hintText: '••••••••',
                                prefixIcon: Icons.lock_outline,
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập mật khẩu';
                                  }
                                  if (value.length < 6) {
                                    return 'Mật khẩu phải từ 6 ký tự trở lên';
                                  }
                                  return null;
                                },
                              ),
                              if (!_isRegistering) ...[
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => context.push('/forgot-password'),
                                    child: const AppText(
                                      'Quên mật khẩu?',
                                      color: AppColors.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),

                              // Submit button
                              AppButton(
                                label: _isRegistering ? 'ĐĂNG KÝ' : 'ĐĂNG NHẬP',
                                onPressed: () => _onSubmitPressed(context),
                                isLoading: authState is AuthLoading,
                              ),
                              const SizedBox(height: 16),

                              // Toggle Mode Button
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isRegistering = !_isRegistering;
                                    _formKey.currentState?.reset();
                                  });
                                },
                                child: AppText(
                                  _isRegistering
                                      ? 'Đã có tài khoản? Đăng nhập ngay'
                                      : 'Chưa có tài khoản? Đăng ký ngay',
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Divider
                              Row(
                                children: [
                                  Expanded(child: Divider(color: AppColors.border(context))),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: AppText(
                                      l10n.login_or_sign_in_with,
                                      fontSize: 12,
                                      color: AppColors.textSecondary(context),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: AppColors.border(context))),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Google button
                              SocialButton(
                                label: l10n.login_google,
                                icon: SvgPicture.asset('assets/icons/google-icon-logo-svgrepo-com.svg', width: 20, height: 20),
                                onPressed: authState is AuthLoading ? () {} : () => _onGoogleLoginPressed(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }
}
