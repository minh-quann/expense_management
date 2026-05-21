import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/widgets/app_button.dart';
import 'package:expense_management/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_management/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_management/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_management/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:expense_management/shared/widgets/app_toast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();

  int _currentStep = 0; // 0: Request reset code, 1: Enter code and reset password

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRequestCodePressed() {
    if (_emailFormKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(ForgotPasswordEvent(_emailController.text.trim()));
    }
  }

  void _onResetPasswordPressed() {
    if (_resetFormKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(ResetPasswordEvent(
            email: _emailController.text.trim(),
            token: _tokenController.text.trim(),
            newPassword: _passwordController.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ForgotPasswordSuccess) {
            AppToast.success(context, 'Mã khôi phục đã được gửi! Vui lòng kiểm tra email.');
            setState(() {
              _tokenController.text = state.token; // Pre-fill token for easy dev testing
              _currentStep = 1;
            });
          } else if (state is ResetPasswordSuccess) {
            AppToast.success(context, state.message);
            context.go('/login');
          } else if (state is AuthFailure) {
            AppToast.error(context, state.message);
          }
        },
        builder: (context, authState) {
          return Stack(
            children: [
              // Full-screen gradient background matching login
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

              SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16, top: 8),
                              child: IconButton(
                                onPressed: () {
                                  if (_currentStep == 1) {
                                    setState(() {
                                      _currentStep = 0;
                                    });
                                  } else {
                                    context.go('/login');
                                  }
                                },
                                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.04),
                          Container(
                            width: 70,
                            height: 70,
                            decoration: ShapeDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: RoundedSuperellipseBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Icon(
                              Icons.lock_reset_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const AppText(
                            'Khôi Phục Mật Khẩu',
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            _currentStep == 0
                                ? 'Nhập email của bạn để nhận mã đặt lại mật khẩu'
                                : 'Nhập mã đã nhận và mật khẩu mới của bạn',
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: ShapeDecoration(
                          color: AppColors.surface(context),
                          shape: const RoundedSuperellipseBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                          ),
                        ),
                        child: _currentStep == 0
                            ? Form(
                                key: _emailFormKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const AppText(
                                      'Yêu Cầu Mã Đặt Lại',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),
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
                                    const SizedBox(height: 32),
                                    AppButton(
                                      label: 'GỬI MÃ KHÔI PHỤC',
                                      onPressed: _onRequestCodePressed,
                                      isLoading: authState is AuthLoading,
                                    ),
                                  ],
                                ),
                              )
                            : Form(
                                key: _resetFormKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const AppText(
                                      'Đặt Lại Mật Khẩu',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),
                                    AuthTextField(
                                      controller: _tokenController,
                                      labelText: 'Mã xác nhận',
                                      hintText: 'Nhập mã gồm 6 số',
                                      prefixIcon: Icons.vpn_key_outlined,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Vui lòng nhập mã xác nhận';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    AuthTextField(
                                      controller: _passwordController,
                                      labelText: 'Mật khẩu mới',
                                      hintText: '••••••••',
                                      prefixIcon: Icons.lock_outline,
                                      obscureText: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Vui lòng nhập mật khẩu mới';
                                        }
                                        if (value.length < 6) {
                                          return 'Mật khẩu phải từ 6 ký tự trở lên';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 32),
                                    AppButton(
                                      label: 'ĐẶT LẠI MẬT KHẨU',
                                      onPressed: _onResetPasswordPressed,
                                      isLoading: authState is AuthLoading,
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
    );
  }
}
