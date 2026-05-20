import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/widgets/app_button.dart';
import 'package:expense_management/features/settings/presentation/bloc/profile_bloc.dart';
import 'package:expense_management/features/settings/presentation/bloc/profile_event.dart';
import 'package:expense_management/features/settings/presentation/bloc/profile_state.dart';
import 'package:expense_management/features/settings/domain/entities/user_profile.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late String _selectedCurrency;
  late String _selectedGender;

  final List<String> _currencies = ['VND', 'USD', 'EUR'];
  final List<Map<String, String>> _genders = [
    {'value': 'male', 'label': 'Nam'},
    {'value': 'female', 'label': 'Nữ'},
    {'value': 'other', 'label': 'Khác'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.displayName);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber);
    _addressController = TextEditingController(text: widget.profile.address);
    _selectedCurrency = widget.profile.currencyCode;
    _selectedGender = widget.profile.gender.isNotEmpty ? widget.profile.gender : 'male';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final bgColor = isDark ? const Color(0xFF161A23) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: AppText(
          'Chỉnh sửa hồ sơ',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        centerTitle: true,
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: AppText('Cập nhật hồ sơ thành công!', color: Colors.white)),
            );
            Navigator.pop(context, state.profile);
          } else if (state is ProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: AppText('Lỗi: ${state.message}', color: Colors.white)),
            );
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            final isLoading = state is ProfileLoading;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        const AppText(
                          'Thông tin cá nhân',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        const SizedBox(height: 20),

                        // Display Name input
                        _buildLabel('Tên hiển thị', isDark),
                        const SizedBox(height: 8),
                        _buildTextField(_nameController, 'Nhập tên hiển thị của bạn', isDark),
                        const SizedBox(height: 20),

                        // Email (Read-only)
                        _buildLabel('Email (Không thể thay đổi)', isDark),
                        const SizedBox(height: 8),
                        _buildReadOnlyTextField(widget.profile.email, isDark),
                        const SizedBox(height: 20),

                        // Phone Number input
                        _buildLabel('Số điện thoại', isDark),
                        const SizedBox(height: 8),
                        _buildTextField(_phoneController, 'Nhập số điện thoại của bạn', isDark, keyboardType: TextInputType.phone),
                        const SizedBox(height: 20),

                        // Address input
                        _buildLabel('Địa chỉ', isDark),
                        const SizedBox(height: 8),
                        _buildTextField(_addressController, 'Nhập địa chỉ của bạn', isDark),
                        const SizedBox(height: 20),

                        // Gender dropdown
                        _buildLabel('Giới tính', isDark),
                        const SizedBox(height: 8),
                        _buildDropdown<String>(
                          value: _selectedGender,
                          items: _genders.map((g) {
                            return DropdownMenuItem<String>(
                              value: g['value'],
                              child: AppText(g['label']!, fontWeight: FontWeight.w600),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedGender = val;
                              });
                            }
                          },
                          isDark: isDark,
                          textColor: textColor,
                        ),
                        const SizedBox(height: 20),

                        // Preferred currency dropdown
                        _buildLabel('Đơn vị tiền tệ chính', isDark),
                        const SizedBox(height: 8),
                        _buildDropdown<String>(
                          value: _selectedCurrency,
                          items: _currencies.map((currency) {
                            return DropdownMenuItem<String>(
                              value: currency,
                              child: AppText(currency, fontWeight: FontWeight.w600),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedCurrency = val;
                              });
                            }
                          },
                          isDark: isDark,
                          textColor: textColor,
                        ),
                      ],
                    ),
                  ),
                ),

                // Save Button (Docked at bottom)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 16.0),
                    child: AppButton(
                      label: 'Lưu thay đổi',
                      isLoading: isLoading,
                      onPressed: () {
                        final name = _nameController.text.trim();
                        if (name.isNotEmpty) {
                          context.read<ProfileBloc>().add(
                                UpdateProfileDetailsEvent(
                                  displayName: name,
                                  currencyCode: _selectedCurrency,
                                  phoneNumber: _phoneController.text.trim(),
                                  address: _addressController.text.trim(),
                                  gender: _selectedGender,
                                ),
                              );
                        }
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String label, bool isDark) {
    return AppText(
      label,
      fontSize: 14,
      color: isDark ? Colors.grey[400] : Colors.grey[600],
      fontWeight: FontWeight.w500,
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText,
    bool isDark, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
        fontFamily: 'Inter',
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontFamily: 'Inter',
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF7F7F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildReadOnlyTextField(String value, bool isDark) {
    return TextField(
      controller: TextEditingController(text: value),
      enabled: false,
      style: TextStyle(
        color: isDark ? Colors.grey[500] : Colors.grey[600],
        fontFamily: 'Inter',
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFEFEFEF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border(context).withValues(alpha: 0.5)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border(context).withValues(alpha: 0.5)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required bool isDark,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          style: TextStyle(
            color: textColor,
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
