import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/widgets/app_button.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/shared/widgets/animated_toggle_bar.dart';
import 'package:expense_management/shared/widgets/custom_number_pad.dart';
import 'package:expense_management/shared/widgets/bento_card.dart';
import 'package:expense_management/shared/widgets/screen_header.dart';
import 'package:expense_management/shared/widgets/bottom_sheet_container.dart';
import 'package:expense_management/shared/utils/category_helper.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:expense_management/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_management/features/categories/presentation/bloc/category_event.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_bloc.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_event.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_state.dart';
import 'package:expense_management/features/transactions/domain/entities/transaction.dart';
import 'package:expense_management/core/utils/auth_token_manager.dart';
import 'package:expense_management/shared/widgets/app_toast.dart';
import 'package:expense_management/features/transactions/presentation/widgets/category_picker_sheet.dart';
import 'package:expense_management/features/transactions/presentation/widgets/wallet_picker_sheet.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String _transactionType = 'EXPENSE'; // EXPENSE, INCOME, TRANSFER
  String _amount = '0';
  final TextEditingController _noteController = TextEditingController();

  // Temporary selection state
  String _selectedCategoryId = '';
  String _selectedCategoryName = 'Chọn danh mục';
  String? _selectedCategoryIcon;
  String? _selectedCategoryColor;
  String _selectedWalletId = '';
  String _selectedWalletName = 'Chọn ví';
  String _selectedToWalletId = '';
  String _selectedToWalletName = 'Chọn ví đích';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Delay loading to prevent transition animation lag
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        final userId = AuthTokenManager.getUserId();
        context.read<WalletBloc>().add(LoadWalletsEvent(userId));
        context.read<CategoryBloc>().add(LoadCategories(userId));
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _showNumberPad() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomNumberPad(
        onNumberPressed: (number) {
          setState(() {
            if (_amount == '0' && number != '000') {
              _amount = number;
            } else if (_amount != '0') {
              _amount += number;
            }
          });
        },
        onBackspacePressed: () {
          setState(() {
            if (_amount.length > 1) {
              _amount = _amount.substring(0, _amount.length - 1);
            } else {
              _amount = '0';
            }
          });
        },
        onDonePressed: () => Navigator.pop(context),
      ),
    );
  }

  void _showCategoryPicker() {
    BottomSheetContainer.show(
      context: context,
      title: 'Chọn danh mục',
      child: CategoryPickerSheet(
        transactionType: _transactionType,
        onCategorySelected: (cat) {
          setState(() {
            _selectedCategoryId = cat.id;
            _selectedCategoryName = cat.name;
            _selectedCategoryIcon = cat.icon;
            _selectedCategoryColor = cat.color;
          });
        },
      ),
    );
  }

  void _showWalletPicker({bool isSource = true}) {
    BottomSheetContainer.show(
      context: context,
      title: isSource ? 'Chọn ví nguồn' : 'Chọn ví đích',
      heightFactor: 0.5,
      child: WalletPickerSheet(
        onWalletSelected: (wallet) {
          setState(() {
            if (isSource) {
              _selectedWalletId = wallet.id;
              _selectedWalletName = wallet.name;
            } else {
              _selectedToWalletId = wallet.id;
              _selectedToWalletName = wallet.name;
            }
          });
        },
      ),
    );
  }

  Future<void> _showDateTimePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _saveTransaction() {
    if (_amount == '0' || _amount.isEmpty) {
      AppToast.warning(context, 'Vui lòng nhập số tiền hợp lệ');
      return;
    }
    if (_selectedWalletId.isEmpty) {
      AppToast.warning(context, 'Vui lòng chọn ví giao dịch');
      return;
    }
    if (_transactionType != 'TRANSFER' && _selectedCategoryId.isEmpty) {
      AppToast.warning(context, 'Vui lòng chọn danh mục');
      return;
    }
    if (_transactionType == 'TRANSFER' && _selectedToWalletId.isEmpty) {
      AppToast.warning(context, 'Vui lòng chọn ví đích');
      return;
    }
    if (_transactionType == 'TRANSFER' &&
        _selectedWalletId == _selectedToWalletId) {
      AppToast.warning(context, 'Ví nguồn và ví đích không được trùng nhau');
      return;
    }

    final userId = AuthTokenManager.getUserId();
    final type = _transactionType == 'EXPENSE'
        ? TransactionType.expense
        : (_transactionType == 'INCOME'
              ? TransactionType.income
              : TransactionType.transfer);

    final transaction = AppTransaction(
      id: '',
      amount: double.parse(_amount),
      type: type,
      categoryId: type == TransactionType.transfer ? null : _selectedCategoryId,
      categoryName: type == TransactionType.transfer
          ? null
          : _selectedCategoryName,
      categoryIcon: type == TransactionType.transfer
          ? null
          : _selectedCategoryIcon,
      categoryColor: type == TransactionType.transfer
          ? null
          : _selectedCategoryColor,
      walletId: _selectedWalletId,
      walletName: _selectedWalletName,
      toWalletId: type == TransactionType.transfer ? _selectedToWalletId : null,
      toWalletName: type == TransactionType.transfer
          ? _selectedToWalletName
          : null,
      date: _selectedDate,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<TransactionBloc>().add(
      AddTransactionEvent(userId, transaction),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state is WalletLoaded && _selectedWalletId.isEmpty) {
          try {
            final fav = state.wallets.firstWhere((w) => w.isFavorite);
            setState(() {
              _selectedWalletId = fav.id;
              _selectedWalletName = fav.name;
            });
          } catch (_) {
            // No favorite wallet found, leave it as is
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: SafeArea(
          child: Column(
            children: [
              ScreenHeader(
                title:
                    AppLocalizations.of(context)?.add_transaction_title ??
                    'Thêm giao dịch mới',
                showBackButton: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTypeToggle(),
                      const SizedBox(height: 40),
                      _buildAmountInput(),
                      const SizedBox(height: 40),
                      _buildDetailsGrid(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: _buildSaveButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    int selectedIndex = 0;
    if (_transactionType == 'INCOME') selectedIndex = 1;
    if (_transactionType == 'TRANSFER') selectedIndex = 2;

    return AnimatedToggleBar(
      options: [
        AppLocalizations.of(context)?.add_transaction_expense ?? 'Chi tiêu',
        AppLocalizations.of(context)?.add_transaction_income ?? 'Thu nhập',
        AppLocalizations.of(context)?.add_transaction_transfer ??
            'Chuyển khoản',
      ],
      selectedIndex: selectedIndex,
      onChanged: (index) {
        setState(() {
          if (index == 0) _transactionType = 'EXPENSE';
          if (index == 1) _transactionType = 'INCOME';
          if (index == 2) _transactionType = 'TRANSFER';
        });
      },
    );
  }

  Widget _buildAmountInput() {
    return GestureDetector(
      onTap: _showNumberPad,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText(
            AppLocalizations.of(context)?.add_transaction_amount ?? 'Số tiền',
            fontSize: 16,
            color: AppColors.textSecondary(context),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: AppText(
                  Localizations.localeOf(context).languageCode == 'vi'
                      ? '₫'
                      : '\$',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: _transactionType == 'EXPENSE'
                      ? AppColors.red500
                      : (_transactionType == 'INCOME'
                            ? AppColors.green500
                            : AppColors.blue500),
                ),
              ),
              const SizedBox(width: 4),
              AppText(
                NumberFormat.decimalPattern(
                  Localizations.localeOf(context).languageCode,
                ).format(double.parse(_amount)),
                fontSize: 56,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _transactionType == 'TRANSFER'
                  ? BentoCard(
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: AppColors.orange500,
                      iconBgColor: AppColors.orange50,
                      title:
                          AppLocalizations.of(
                            context,
                          )?.add_transaction_source_wallet ??
                          'Ví nguồn',
                      value: _selectedWalletName,
                      onTap: () => _showWalletPicker(isSource: true),
                    )
                  : BentoCard(
                      icon: _selectedCategoryIcon != null
                          ? CategoryHelper.getIcon(_selectedCategoryIcon!)
                          : Icons.grid_view_rounded,
                      iconColor: _selectedCategoryColor != null
                          ? CategoryHelper.getColor(_selectedCategoryColor!)
                          : AppColors.purple500,
                      iconBgColor: _selectedCategoryColor != null
                          ? CategoryHelper.getColor(
                              _selectedCategoryColor!,
                            ).withValues(alpha: 0.1)
                          : AppColors.purple50,
                      title:
                          AppLocalizations.of(
                            context,
                          )?.add_transaction_category ??
                          'Danh mục',
                      value: _selectedCategoryName,
                      onTap: _showCategoryPicker,
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _transactionType == 'TRANSFER'
                  ? BentoCard(
                      icon: Icons.account_balance_wallet_rounded,
                      iconColor: AppColors.blue500,
                      iconBgColor: AppColors.blue50,
                      title:
                          AppLocalizations.of(
                            context,
                          )?.add_transaction_destination_wallet ??
                          'Ví đích',
                      value: _selectedToWalletName,
                      onTap: () => _showWalletPicker(isSource: false),
                    )
                  : BentoCard(
                      icon: Icons.account_balance_wallet_rounded,
                      iconColor: AppColors.blue500,
                      iconBgColor: AppColors.blue50,
                      title:
                          AppLocalizations.of(
                            context,
                          )?.add_transaction_wallet ??
                          'Ví',
                      value: _selectedWalletName,
                      onTap: () => _showWalletPicker(isSource: true),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: BentoCard(
            icon: Icons.calendar_today_rounded,
            iconColor: AppColors.orange500,
            iconBgColor: AppColors.orange50,
            title: AppLocalizations.of(context)?.add_transaction_date ?? 'Ngày',
            value: DateFormat('dd/MM/yyyy, HH:mm').format(_selectedDate),
            onTap: _showDateTimePicker,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: ShapeDecoration(
            color: AppColors.isDark(context)
                ? AppColors.surface(context)
                : Colors.white,
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(26),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: ShapeDecoration(
                  color: AppColors.gray50,
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.gray500,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.of(
                          context,
                        )?.add_transaction_note_hint ??
                        'Thêm ghi chú...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return AppButton(
      label:
          AppLocalizations.of(context)?.add_transaction_save ?? 'Lưu giao dịch',
      onPressed: _saveTransaction,
      height: 60,
    );
  }
}
