import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/features/app_lock/presentation/bloc/app_lock_bloc.dart';
import 'package:expense_management/features/app_lock/presentation/bloc/app_lock_event.dart';
import 'package:expense_management/features/app_lock/presentation/bloc/app_lock_state.dart';
import 'package:expense_management/features/app_lock/presentation/widgets/pin_dots.dart';
import 'package:expense_management/features/app_lock/presentation/widgets/lock_number_pad.dart';
import 'package:expense_management/features/app_lock/presentation/screens/pin_recovery_screen.dart';
import 'package:expense_management/shared/widgets/app_button.dart';

/// Lock screen displayed when the app is locked.
/// Supports PIN entry and biometric authentication.
class LockScreen extends StatefulWidget {
  /// Callback when the app is successfully unlocked
  final VoidCallback? onUnlocked;

  /// If true, this is a setup screen (for creating new PIN)
  final bool isSetup;

  /// Callback when setup is complete (PIN saved)
  final VoidCallback? onSetupComplete;

  /// Callback when the PIN is verified (e.g. for changing or disabling PIN)
  final void Function(String pin)? onVerified;

  /// Custom title to display
  final String? title;

  /// Custom subtitle to display
  final String? subtitle;

  const LockScreen({
    super.key, 
    this.onUnlocked, 
    this.isSetup = false,
    this.onSetupComplete,
    this.onVerified,
    this.title,
    this.subtitle,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0);
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return BlocConsumer<AppLockBloc, AppLockState>(
      listener: (context, state) {
        if (state is AppUnlocked) {
          if (widget.onVerified != null) {
            widget.onVerified!(state.pin ?? '');
          } else {
            widget.onUnlocked?.call();
          }
        }
        if (state is AppLocked && state.errorMessage != null) {
          _triggerShake();
        }
        if (state is AppLockSettings && state.isLockEnabled) {
          widget.onSetupComplete?.call();
        }
        if (state is AppLockSetupSecurityRequired) {
          _showSecurityQuestionSetup(context, state.pin);
        }
        if (state is AppLockActionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppText(state.error, color: Colors.white),
              backgroundColor: AppColors.error,
            ),
          );
        }
        if (state is AppLockActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppText(state.message, color: Colors.white),
              backgroundColor: AppColors.green600,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is! AppLocked) {
          return const SizedBox.shrink();
        }

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: Colors.transparent,
          ),
          child: Scaffold(
            backgroundColor: isDark ? const Color(0xFF000000) : Colors.white,
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      const Spacer(flex: 2),

                      // Lock icon with glow
                      _buildLockIcon(isDark, state),

                      const SizedBox(height: 24),

                      // Title
                      AppText(
                        _getTitle(state.mode),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.gray900,
                      ),

                      const SizedBox(height: 8),

                      // Subtitle
                      AppText(
                        _getSubtitle(state.mode),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.gray500,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // PIN dots with shake animation
                      AnimatedBuilder(
                        animation: _shakeAnimation,
                        builder: (context, child) {
                          final shakeOffset = _shakeAnimation.value *
                              10 *
                              ((_shakeController.value * 8).toInt().isOdd ? 1 : -1);
                          return Transform.translate(
                            offset: Offset(shakeOffset, 0),
                            child: child,
                          );
                        },
                        child: PinDots(
                          pinLength: AppLockBloc.pinLength,
                          enteredLength: state.enteredPin.length,
                          hasError: state.errorMessage != null,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Error message
                      AnimatedOpacity(
                        opacity: state.errorMessage != null ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: SizedBox(
                          height: 20,
                          child: AppText(
                            state.errorMessage ?? '',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.error,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      if (state.mode == LockScreenMode.unlock) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => _navigateToRecovery(),
                          child: const AppText(
                            'Quên mã PIN?',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],

                      const Spacer(flex: 1),

                      // Number pad
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: LockNumberPad(
                          onDigitPressed: (digit) {
                            context.read<AppLockBloc>().add(EnterPinDigit(digit));
                          },
                          onDeletePressed: () {
                            context.read<AppLockBloc>().add(DeletePinDigit());
                          },
                          showBiometric: state.mode == LockScreenMode.unlock &&
                              state.isBiometricAvailable &&
                              state.isBiometricEnabled,
                          onBiometricPressed: () {
                            context.read<AppLockBloc>().add(AuthenticateWithBiometrics());
                          },
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                  if (Navigator.canPop(context))
                    Positioned(
                      top: 8,
                      left: 16,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: isDark ? Colors.white : AppColors.gray900,
                        ),
                        onPressed: () {
                          context.read<AppLockBloc>().add(ClearPin());
                          Navigator.pop(context);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLockIcon(bool isDark, AppLocked state) {
    final isError = state.errorMessage != null;
    final color = isError ? AppColors.error : AppColors.primary;

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isError
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.05),
                ],
              ),
        color: isError ? AppColors.error.withValues(alpha: 0.1) : null,
      ),
      child: Icon(
        state.mode == LockScreenMode.unlock
            ? Icons.lock_outline_rounded
            : Icons.lock_open_rounded,
        size: 34,
        color: color,
      ),
    );
  }

  String _getTitle(LockScreenMode mode) {
    if (mode == LockScreenMode.unlock && widget.title != null) {
      return widget.title!;
    }
    switch (mode) {
      case LockScreenMode.unlock:
        return 'Nhập mã PIN';
      case LockScreenMode.setup:
        return 'Tạo mã PIN mới';
      case LockScreenMode.confirm:
        return 'Xác nhận mã PIN';
    }
  }

  String _getSubtitle(LockScreenMode mode) {
    if (mode == LockScreenMode.unlock && widget.subtitle != null) {
      return widget.subtitle!;
    }
    switch (mode) {
      case LockScreenMode.unlock:
        return 'Nhập mã PIN để mở khóa ứng dụng';
      case LockScreenMode.setup:
        return 'Tạo mã PIN 4 chữ số để bảo vệ ứng dụng';
      case LockScreenMode.confirm:
        return 'Nhập lại mã PIN để xác nhận';
    }
  }

  Future<void> _navigateToRecovery() async {
    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PinRecoveryScreen()),
    );
    if (success == true && mounted) {
      context.read<AppLockBloc>().add(UnlockApp());
    }
  }

  void _showSecurityQuestionSetup(BuildContext context, String pin) {
    final isDark = AppColors.isDark(context);
    final answerController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    final List<String> suggestedQuestions = [
      'Tên thú cưng đầu tiên của bạn là gì?',
      'Tên trường tiểu học đầu tiên của bạn là gì?',
      'Thành phố nơi cha mẹ bạn gặp nhau?',
      'Biệt danh thời thơ ấu của bạn là gì?',
      'Món ăn yêu thích nhất của bạn là gì?',
    ];

    String selectedQuestion = suggestedQuestions[0];
    final customQuestionController = TextEditingController();
    bool isCustomQuestion = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppText(
                      'Thiết lập câu hỏi bảo mật',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.gray900,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      'Câu hỏi này được sử dụng để khôi phục mã PIN trong trường hợp bạn quên.',
                      fontSize: 13,
                      color: AppColors.gray500,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    
                    if (!isCustomQuestion) ...[
                      DropdownButtonFormField<String>(
                        initialValue: selectedQuestion,
                        dropdownColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                        style: TextStyle(color: isDark ? Colors.white : AppColors.gray900),
                        decoration: const InputDecoration(
                          labelText: 'Chọn câu hỏi bảo mật',
                          border: OutlineInputBorder(),
                        ),
                        items: suggestedQuestions.map((q) {
                          return DropdownMenuItem<String>(
                            value: q,
                            child: AppText(q, fontSize: 14),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setSheetState(() => selectedQuestion = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          setSheetState(() => isCustomQuestion = true);
                        },
                        child: const AppText('Tự nhập câu hỏi của bạn', color: AppColors.primary),
                      ),
                    ] else ...[
                      TextFormField(
                        controller: customQuestionController,
                        style: TextStyle(color: isDark ? Colors.white : AppColors.gray900),
                        decoration: const InputDecoration(
                          labelText: 'Nhập câu hỏi bảo mật của bạn',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập câu hỏi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          setSheetState(() => isCustomQuestion = false);
                        },
                        child: const AppText('Chọn câu hỏi có sẵn', color: AppColors.primary),
                      ),
                    ],

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: answerController,
                      style: TextStyle(color: isDark ? Colors.white : AppColors.gray900),
                      decoration: const InputDecoration(
                        labelText: 'Câu trả lời bảo mật',
                        border: OutlineInputBorder(),
                        helperText: 'Lưu ý: Không phân biệt chữ hoa/thường',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập câu trả lời';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    AppButton(
                      label: 'Lưu & Kích hoạt PIN',
                      isLoading: isSaving,
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setSheetState(() => isSaving = true);
                          final finalQuestion = isCustomQuestion
                              ? customQuestionController.text.trim()
                              : selectedQuestion;
                          final finalAnswer = answerController.text.trim();

                          Navigator.pop(sheetContext);

                          context.read<AppLockBloc>().add(
                                SavePinWithSecurity(
                                  pin: pin,
                                  question: finalQuestion,
                                  answer: finalAnswer,
                                ),
                              );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
