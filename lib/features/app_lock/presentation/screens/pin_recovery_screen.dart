import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/features/app_lock/data/services/app_lock_service.dart';
import 'package:expense_management/shared/widgets/app_button.dart';
import 'package:expense_management/shared/widgets/app_toast.dart';
import 'package:expense_management/shared/widgets/screen_header.dart';
import 'package:expense_management/shared/widgets/fading_blur_layer.dart';

/// Screen displayed when user forgets PIN code.
/// Loads the security question from backend and allows resetting PIN.
class PinRecoveryScreen extends StatefulWidget {
  const PinRecoveryScreen({super.key});

  @override
  State<PinRecoveryScreen> createState() => _PinRecoveryScreenState();
}

class _PinRecoveryScreenState extends State<PinRecoveryScreen> {
  final AppLockService _service = AppLockService();
  final _formKey = GlobalKey<FormState>();
  final _answerController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  String? _securityQuestion;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSecurityQuestion();
  }

  @override
  void dispose() {
    _answerController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _loadSecurityQuestion() async {
    try {
      final question = await _service.getSecurityQuestion();
      if (mounted) {
        setState(() {
          _securityQuestion = question;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Không thể tải câu hỏi bảo mật. Có thể bạn chưa thiết lập.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetPin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final answer = _answerController.text.trim();
      final newPin = _newPinController.text.trim();

      await _service.resetPin(answer, newPin);

      if (mounted) {
        AppToast.success(context, 'Khôi phục mã PIN thành công!');
        // Pop and return true to indicate success
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Câu trả lời bảo mật không đúng hoặc mã PIN không hợp lệ.';
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final bgColor = AppColors.background(context);
    final textColor = isDark ? Colors.white : AppColors.gray900;
    final cardColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF7F7F9);
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final headerHeight = statusBarHeight + 64.0;

    Widget buildButton() {
      if (_securityQuestion != null) {
        return AppButton(
          label: 'Đặt lại mã PIN & Mở khóa',
          isLoading: _isSaving,
          onPressed: _resetPin,
        );
      } else {
        return AppButton(
          label: 'Quay lại',
          onPressed: () => Navigator.pop(context),
        );
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. Content
          Positioned.fill(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(24, headerHeight + 16, 24, 16),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Illustration / Header icon
                                Center(
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                    ),
                                    child: const Icon(
                                      Icons.lock_reset_rounded,
                                      size: 40,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                if (_errorMessage != null) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: ShapeDecoration(
                                      color: AppColors.error.withValues(alpha: 0.1),
                                      shape: RoundedSuperellipseBorder(
                                        side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: AppText(
                                      _errorMessage!,
                                      color: AppColors.error,
                                      fontSize: 13,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],

                                if (_securityQuestion != null) ...[
                                  // Question Box
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
                                        AppText(
                                          'Câu hỏi bảo mật của bạn:',
                                          fontSize: 12,
                                          color: AppColors.gray500,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        const SizedBox(height: 6),
                                        AppText(
                                          _securityQuestion!,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: textColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Answer input
                                  TextFormField(
                                    controller: _answerController,
                                    style: TextStyle(color: textColor),
                                    decoration: const InputDecoration(
                                      labelText: 'Câu trả lời của bạn',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Vui lòng nhập câu trả lời';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // New PIN input
                                  TextFormField(
                                    controller: _newPinController,
                                    obscureText: true,
                                    keyboardType: TextInputType.number,
                                    maxLength: 4,
                                    style: TextStyle(color: textColor),
                                    decoration: const InputDecoration(
                                      labelText: 'Mã PIN mới (4 chữ số)',
                                      border: OutlineInputBorder(),
                                      counterText: '',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.length < 4) {
                                        return 'Vui lòng nhập đủ 4 chữ số';
                                      }
                                      if (int.tryParse(value) == null) {
                                        return 'Mã PIN chỉ được chứa các chữ số';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // Confirm New PIN input
                                  TextFormField(
                                    controller: _confirmPinController,
                                    obscureText: true,
                                    keyboardType: TextInputType.number,
                                    maxLength: 4,
                                    style: TextStyle(color: textColor),
                                    decoration: const InputDecoration(
                                      labelText: 'Xác nhận mã PIN mới',
                                      border: OutlineInputBorder(),
                                      counterText: '',
                                    ),
                                    validator: (value) {
                                      if (value != _newPinController.text) {
                                        return 'Mã PIN xác nhận không trùng khớp';
                                      }
                                      return null;
                                    },
                                  ),
                                ] else ...[
                                  // If no question was found
                                  const SizedBox(height: 40),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: buildButton(),
                      ),
                    ],
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
                      title: 'Khôi phục mã PIN',
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
}
