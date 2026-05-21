import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/features/app_lock/data/services/app_lock_service.dart';
import 'package:expense_management/shared/widgets/app_button.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: AppText('Khôi phục mã PIN thành công!', color: Colors.white),
            backgroundColor: AppColors.green600,
          ),
        );
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
    final bgColor = isDark ? const Color(0xFF000000) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.gray900;
    final cardColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF7F7F9);

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
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: AppText(
          'Khôi phục mã PIN',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
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
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(16),
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
                                      fontWeight: FontWeight.w600,
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
    );
  }
}
