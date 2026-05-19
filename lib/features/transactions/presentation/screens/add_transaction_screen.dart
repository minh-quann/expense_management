import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/shared/widgets/animated_toggle_bar.dart';
import 'package:expense_management/shared/widgets/custom_number_pad.dart';
import 'package:expense_management/shared/utils/category_helper.dart';
import 'package:expense_management/shared/utils/currency_formatter.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:expense_management/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_management/features/categories/presentation/bloc/category_event.dart';
import 'package:expense_management/features/categories/presentation/bloc/category_state.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_bloc.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_event.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_state.dart';
import 'package:expense_management/features/transactions/domain/entities/transaction.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'test_user';
    context.read<WalletBloc>().add(LoadWalletsEvent(userId));
    context.read<CategoryBloc>().add(LoadCategories(userId));
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.isDark(context)
                ? AppColors.surface(context)
                : Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Chọn danh mục',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    if (state is CategoryLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is CategoryLoaded) {
                      final categories = _transactionType == 'INCOME'
                          ? state.incomeCategories
                          : state.expenseCategories;
                      if (categories.isEmpty) {
                        return Center(
                          child: AppText(
                            'Chưa có danh mục nào',
                            color: AppColors.textSecondary(context),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          return Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                leading: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: CategoryHelper.getColor(
                                      cat.color,
                                    ).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    CategoryHelper.getIcon(cat.icon),
                                    color: CategoryHelper.getColor(cat.color),
                                    size: 24,
                                  ),
                                ),
                                title: AppText(
                                  cat.name,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary(context),
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textSecondary(context),
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedCategoryId = cat.id;
                                    _selectedCategoryName = cat.name;
                                    _selectedCategoryIcon = cat.icon;
                                    _selectedCategoryColor = cat.color;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              if (index < categories.length - 1)
                                Divider(
                                  height: 1,
                                  indent: 64,
                                  color: AppColors.border(context),
                                ),
                            ],
                          );
                        },
                      );
                    }
                    return Center(
                      child: AppText(
                        'Lỗi tải danh mục',
                        color: AppColors.textSecondary(context),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWalletPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.isDark(context)
                ? AppColors.surface(context)
                : Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Chọn ví',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: BlocBuilder<WalletBloc, WalletState>(
                  builder: (context, state) {
                    if (state is WalletLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is WalletLoaded) {
                      if (state.wallets.isEmpty) {
                        return Center(
                          child: AppText(
                            'Chưa có ví nào',
                            color: AppColors.textSecondary(context),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.wallets.length,
                        itemBuilder: (context, index) {
                          final wallet = state.wallets[index];
                          return Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                leading: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.blue500.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet,
                                    color: AppColors.blue500,
                                    size: 24,
                                  ),
                                ),
                                title: AppText(
                                  wallet.name,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary(context),
                                ),
                                subtitle: AppText(
                                  CurrencyFormatter.format(
                                    context,
                                    wallet.balance,
                                  ),
                                  color: AppColors.textSecondary(context),
                                  fontSize: 13,
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textSecondary(context),
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedWalletId = wallet.id;
                                    _selectedWalletName = wallet.name;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              if (index < state.wallets.length - 1)
                                Divider(
                                  height: 1,
                                  indent: 64,
                                  color: AppColors.border(context),
                                ),
                            ],
                          );
                        },
                      );
                    }
                    return Center(
                      child: AppText(
                        'Lỗi tải ví',
                        color: AppColors.textSecondary(context),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')),
      );
      return;
    }

    if (_selectedWalletId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ví giao dịch')),
      );
      return;
    }

    if (_transactionType != 'TRANSFER' && _selectedCategoryId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn danh mục')));
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'test_user';

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
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
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
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.isDark(context)
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.gray100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary(context),
                size: 20,
              ),
            ),
          ),
          AppText(
            AppLocalizations.of(context)?.add_transaction_title ??
                'Thêm giao dịch',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildTypeToggle() {
    int selectedIndex = 0;
    if (_transactionType == 'INCOME') {
      selectedIndex = 1;
    } else if (_transactionType == 'TRANSFER') {
      selectedIndex = 2;
    }

    return AnimatedToggleBar(
      options: [
        AppLocalizations.of(context)?.add_transaction_expense ?? 'Chi tiền',
        AppLocalizations.of(context)?.add_transaction_income ?? 'Thu tiền',
        AppLocalizations.of(context)?.add_transaction_transfer ??
            'Chuyển khoản',
      ],
      selectedIndex: selectedIndex,
      onChanged: (index) {
        setState(() {
          if (index == 0) {
            _transactionType = 'EXPENSE';
          } else if (index == 1) {
            _transactionType = 'INCOME';
          } else if (index == 2) {
            _transactionType = 'TRANSFER';
          }
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
                  fontWeight: FontWeight.bold,
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
                fontWeight: FontWeight.bold,
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
              child: _buildBentoCard(
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
                    AppLocalizations.of(context)?.add_transaction_category ??
                    'Danh mục',
                value: _selectedCategoryName,
                onTap: _showCategoryPicker,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildBentoCard(
                icon: Icons.account_balance_wallet_rounded,
                iconColor: AppColors.blue500,
                iconBgColor: AppColors.blue50,
                title:
                    AppLocalizations.of(context)?.add_transaction_wallet ??
                    'Ví',
                value: _selectedWalletName,
                onTap: _showWalletPicker,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildBentoCard(
                icon: Icons.calendar_today_rounded,
                iconColor: AppColors.orange500,
                iconBgColor: AppColors.orange50,
                title:
                    AppLocalizations.of(context)?.add_transaction_date ??
                    'Ngày',
                value:
                    '${_isToday(_selectedDate) ? (AppLocalizations.of(context)?.transactions_today ?? 'Hôm nay') : DateFormat('dd/MM/yyyy').format(_selectedDate)}, ${DateFormat('HH:mm').format(_selectedDate)}',
                onTap: _showDateTimePicker,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.isDark(context)
                ? AppColors.surface(context)
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(16),
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
                        'Ghi chú',
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

  Widget _buildBentoCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.isDark(context)
              ? AppColors.surface(context)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 16),
            AppText(
              title,
              fontSize: 13,
              color: AppColors.textSecondary(context),
            ),
            const SizedBox(height: 4),
            AppText(
              value,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: AppText(
          AppLocalizations.of(context)?.add_transaction_save ?? 'Lưu',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
