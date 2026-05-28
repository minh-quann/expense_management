import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/core/utils/auth_token_manager.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/widgets/app_button.dart';
import 'package:expense_management/shared/utils/currency_formatter.dart';
import 'package:expense_management/shared/widgets/transaction_item_builder.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_bloc.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_event.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_state.dart';
import 'package:expense_management/features/wallets/domain/entities/wallet.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_state.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/shared/widgets/screen_header.dart';

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key});
 
  @override
  State<WalletsScreen> createState() => _WalletsScreenState(); 
}

class _WalletsScreenState extends State<WalletsScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;

  final List<LinearGradient> _cardGradients = [
    const LinearGradient(colors: [Color(0xFF134E5E), Color(0xFF71B280)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    const LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    const LinearGradient(colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    const LinearGradient(colors: [Color(0xFF1E3C72), Color(0xFF2A5298)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  ];

  @override
  void initState() {
    super.initState();
    // Delay loading to prevent transition animation lag
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        final userId = AuthTokenManager.getUserId();
        context.read<WalletBloc>().add(LoadWalletsEvent(userId));
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final bgColor = AppColors.background(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: AppLocalizations.of(context)!.wallets_title,
              showBackButton: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScreenHeader.circleButton(
                    context: context,
                    onTap: () {},
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.textPrimary(context),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ScreenHeader.circleButton(
                    context: context,
                    onTap: () {},
                    child: Icon(
                      Icons.search_rounded,
                      color: AppColors.textPrimary(context),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<WalletBloc, WalletState>(
                builder: (context, state) {
                  if (state is WalletLoading) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  } else if (state is WalletLoaded) {
                    final double totalBalance = state.wallets
                        .where((w) => !w.excludeFromTotal)
                        .fold(0, (sum, w) => sum + w.balance);
                    
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header - Total Balance
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(AppLocalizations.of(context)!.wallets_total_assets, fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.textPrimary(context)),
                                const SizedBox(height: 4),
                                AppText(
                                  CurrencyFormatter.format(context, totalBalance),
                                  fontSize: 32,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary(context),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Horizontal Card Carousel
                          SizedBox(
                            height: 200,
                            child: state.wallets.isEmpty 
                              ? _buildEmptyWalletCard(context)
                              : PageView.builder(
                                  controller: _pageController,
                                  onPageChanged: (int page) {
                                    setState(() {
                                      _currentPage = page;
                                    });
                                  },
                                  itemCount: state.wallets.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == state.wallets.length) {
                                      return _buildAddWalletCard(context);
                                    }
                                    final wallet = state.wallets[index];
                                    final gradient = _cardGradients[index % _cardGradients.length];
                                    return _buildWalletCard(context, wallet, gradient);
                                  },
                                ),
                          ),
                          
                          // Page Indicators
                          if (state.wallets.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  state.wallets.length + 1,
                                  (index) => Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: _currentPage == index ? 24 : 8,
                                    height: 4,
                                    decoration: ShapeDecoration(
                                      color: _currentPage == index 
                                          ? AppColors.textPrimary(context).withValues(alpha: 0.8) 
                                          : AppColors.textSecondary(context).withValues(alpha: 0.4),
                                      shape: RoundedSuperellipseBorder(
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          
                          const SizedBox(height: 32),
                          
                          // Recent Transactions Header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppText('GIAO DỊCH GẦN ĐÂY', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary(context)),
                                AppText('Xem tất cả', fontSize: 13, color: AppColors.textSecondary(context)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Real Transactions from Firebase
                          _buildRealTransactionsList(context),
                          
                          const SizedBox(height: 32),
                        ],
                      ),
                    );
                  } else if (state is WalletError) {
                    return Center(child: AppText(state.message, color: AppColors.error));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build real transactions list from TransactionBloc
  Widget _buildRealTransactionsList(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoaded) {
          final recentTx = state.transactions.take(5).toList();

          if (recentTx.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: AppText('Chưa có giao dịch nào', color: AppColors.textSecondary(context)),
              ),
            );
          }

          return Column(
            children: recentTx.map((tx) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                child: TransactionItemBuilder.buildItem(context: context, tx: tx),
              );
            }).toList(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyWalletCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: ShapeDecoration(
        color: AppColors.surface(context),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(26),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 48, color: AppColors.textSecondary(context)),
            const SizedBox(height: 16),
            AppText(AppLocalizations.of(context)!.wallets_add, color: AppColors.textSecondary(context)),
            const SizedBox(height: 16),
            AppButton(
              label: AppLocalizations.of(context)!.wallets_add,
              onPressed: () => _showAddWalletSheet(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddWalletCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddWalletSheet(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: ShapeDecoration(
          color: AppColors.surface(context),
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, size: 32, color: AppColors.textPrimary(context)),
            ),
            const SizedBox(height: 16),
            AppText(AppLocalizations.of(context)!.wallets_add, fontWeight: FontWeight.w500),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context, Wallet wallet, LinearGradient gradient) {
    return GestureDetector(
      onTap: () => _showEditWalletSheet(context, wallet),
      onLongPress: () => _showDeleteWalletConfirmation(context, wallet),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(20),
        decoration: ShapeDecoration(
          gradient: gradient,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          shadows: [
            BoxShadow(
              color: gradient.colors.last.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Stack(
          children: [
            // Glassmorphism decor
            Positioned(
              right: -30,
              bottom: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Wallet Name & Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: AppText(
                              wallet.name,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              context.read<WalletBloc>().add(
                                ToggleFavoriteWalletEvent(wallet.userId, wallet.id),
                              );
                            },
                            child: Icon(
                              wallet.isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                              color: wallet.isFavorite ? const Color(0xFFFF5252) : Colors.white70,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Fake Mastercard Logo
                    SizedBox(
                      width: 40,
                      height: 24,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Middle Row: Card Number & Cardholder
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText('•••• 1122', fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
                    const SizedBox(height: 2),
                    AppText('Tên chủ thẻ', fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
                  ],
                ),
                
                // Bottom Row: Balance & VISA text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText('SỐ DƯ', fontSize: 10, color: Colors.white.withValues(alpha: 0.8)),
                        const SizedBox(height: 2),
                        AppText(
                          CurrencyFormatter.format(context, wallet.balance),
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const AppText('VISA', fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWalletSheet(BuildContext context) {
    final userId = AuthTokenManager.getUserId();
    
    String name = '';
    double balance = 0;
 
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            left: 24,
            right: 24,
            top: 24, // increased top padding for better visual
          ),
          decoration: ShapeDecoration(
            color: AppColors.surface(context),
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: ShapeDecoration(
                  color: AppColors.border(context),
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: AppText(AppLocalizations.of(context)!.wallets_add, fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: ShapeDecoration(
                  color: AppColors.background(context),
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Tên ví (vd: Tiền mặt, Techcombank)',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  onChanged: (val) => name = val,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: ShapeDecoration(
                  color: AppColors.background(context),
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Số dư ban đầu (₫)',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => balance = double.tryParse(val) ?? 0,
                ),
              ),
              const SizedBox(height: 32),
              AppButton(
                label: AppLocalizations.of(context)!.wallets_add,
                onPressed: () {
                  if (name.isNotEmpty) {
                    final newWallet = Wallet(
                      id: '', 
                      userId: userId,
                      name: name,
                      type: WalletType.cash, 
                      balance: balance,
                      currency: 'VND',
                      icon: '',
                      color: '',
                      excludeFromTotal: false,
                    );
                    context.read<WalletBloc>().add(AddWalletEvent(newWallet));
                    Navigator.pop(ctx);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditWalletSheet(BuildContext context, Wallet wallet) {
    final userId = AuthTokenManager.getUserId();
    final nameController = TextEditingController(text: wallet.name);
    final balanceController = TextEditingController(text: wallet.balance.toStringAsFixed(0));
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            left: 24,
            right: 24,
            top: 24,
          ),
          decoration: ShapeDecoration(
            color: AppColors.surface(context),
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: ShapeDecoration(
                  color: AppColors.border(context),
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: const AppText('Chỉnh sửa ví', fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: ShapeDecoration(
                  color: AppColors.background(context),
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Tên ví (vd: Tiền mặt, Techcombank)',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: ShapeDecoration(
                  color: AppColors.background(context),
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: TextField(
                  controller: balanceController,
                  decoration: const InputDecoration(
                    hintText: 'Số dư (₫)',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 32),
              AppButton(
                label: 'Lưu thay đổi',
                onPressed: () {
                  final name = nameController.text.trim();
                  final balance = double.tryParse(balanceController.text) ?? 0.0;
                  if (name.isNotEmpty) {
                    final updatedWallet = Wallet(
                      id: wallet.id,
                      userId: userId,
                      name: name,
                      type: wallet.type,
                      balance: balance,
                      currency: wallet.currency,
                      icon: wallet.icon,
                      color: wallet.color,
                      excludeFromTotal: wallet.excludeFromTotal,
                      isFavorite: wallet.isFavorite,
                    );
                    context.read<WalletBloc>().add(UpdateWalletEvent(updatedWallet));
                    Navigator.pop(ctx);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteWalletConfirmation(BuildContext context, Wallet wallet) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedSuperellipseBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        title: const AppText('Xóa ví', fontWeight: FontWeight.w600),
        content: AppText('Bạn có chắc chắn muốn xóa ví "${wallet.name}"? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: AppText('Hủy', color: AppColors.textSecondary(context)),
          ),
          TextButton(
            onPressed: () {
              final userId = AuthTokenManager.getUserId();
              context.read<WalletBloc>().add(DeleteWalletEvent(userId, wallet.id));
              Navigator.pop(ctx);
            },
            child: const AppText('Xóa', color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
