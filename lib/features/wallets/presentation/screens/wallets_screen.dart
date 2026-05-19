import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_bloc.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_event.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_state.dart';
import 'package:expense_management/features/wallets/domain/entities/wallet.dart';
import 'package:expense_management/l10n/app_localizations.dart';

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key});
 
  @override
  State<WalletsScreen> createState() => _WalletsScreenState(); 
}

class _WalletsScreenState extends State<WalletsScreen> {
  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
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
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<WalletBloc>().add(LoadWalletsEvent(user.uid));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The background should be a deep elegant matte black.
    final bgColor = AppColors.isDark(context) ? const Color(0xFF161A23) : const Color(0xFFF0F2F5);
    final isDark = AppColors.isDark(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 28),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search, size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          } else if (state is WalletLoaded) {
            final double totalBalance = state.wallets.fold(0, (sum, w) => sum + w.balance);
            
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
                        AppText(AppLocalizations.of(context)!.wallets_total_assets, fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary(context)),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AppText(
                              _currencyFormat.format(totalBalance),
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary(context),
                            ),
                            const SizedBox(width: 8),
                            AppText('VND', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textSecondary(context)),
                            Icon(Icons.arrow_drop_down, color: AppColors.textSecondary(context)),
                          ],
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
                          itemCount: state.wallets.length + 1, // +1 for "Add Wallet" card
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
                            decoration: BoxDecoration(
                              color: _currentPage == index 
                                  ? AppColors.textPrimary(context).withValues(alpha: 0.8) 
                                  : AppColors.textSecondary(context).withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(2),
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
                        AppText('GIAO DỊCH GẦN ĐÂY', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary(context)),
                        AppText('Xem tất cả', fontSize: 13, color: AppColors.textSecondary(context)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Recent Transactions List (Dummy Data matching the mockup)
                  _buildTransactionItem(
                    context, 
                    icon: Icons.shopping_cart_outlined, 
                    title: 'Amazon Prime', 
                    subtitle: 'Mua sắm', 
                    amount: '-₫350.000', 
                    time: 'Hôm nay',
                    isPositive: false,
                    isDark: isDark,
                  ),
                  _buildTransactionItem(
                    context, 
                    icon: Icons.arrow_downward, 
                    title: 'Tiền lương', 
                    subtitle: 'Hôm qua', 
                    amount: '+₫38.500.000', 
                    time: 'Hôm qua',
                    isPositive: true,
                    iconColor: AppColors.success,
                    isDark: isDark,
                  ),
                  _buildTransactionItem(
                    context, 
                    icon: Icons.music_note, 
                    title: 'Spotify', 
                    subtitle: '24 thg 10', 
                    amount: '-₫59.000', 
                    time: '24 thg 10',
                    isPositive: false,
                    isDark: isDark,
                    iconColor: const Color(0xFF1DB954),
                  ),
                  _buildTransactionItem(
                    context, 
                    icon: Icons.directions_car_outlined, 
                    title: 'Uber Ride', 
                    subtitle: '23 thg 10', 
                    amount: '-₫120.000', 
                    time: '23 thg 10',
                    isPositive: false,
                    isDark: isDark,
                  ),
                  _buildTransactionItem(
                    context, 
                    icon: Icons.local_cafe_outlined, 
                    title: 'Starbucks Coffee', 
                    subtitle: '22 thg 10', 
                    amount: '-₫85.000', 
                    time: '22 thg 10',
                    isPositive: false,
                    isDark: isDark,
                    iconColor: const Color(0xFF00704A),
                  ),
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
    );
  }

  Widget _buildTransactionItem(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required String time,
    required bool isPositive,
    required bool isDark,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2E39) : const Color(0xFFE2E4E9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor ?? AppColors.textPrimary(context), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(title, fontSize: 16, fontWeight: FontWeight.w600),
                const SizedBox(height: 4),
                AppText(subtitle, fontSize: 13, color: AppColors.textSecondary(context)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText(
                amount, 
                fontSize: 16, 
                fontWeight: FontWeight.w600, 
                color: isPositive ? AppColors.success : AppColors.textPrimary(context),
              ),
              const SizedBox(height: 4),
              AppText(time, fontSize: 13, color: AppColors.textSecondary(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWalletCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 48, color: AppColors.textSecondary(context)),
            const SizedBox(height: 16),
            AppText(AppLocalizations.of(context)!.wallets_add, color: AppColors.textSecondary(context)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showAddWalletSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: AppText(AppLocalizations.of(context)!.wallets_add),
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
        decoration: BoxDecoration(
          color: AppColors.surface(context).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border(context), style: BorderStyle.solid),
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
            AppText(AppLocalizations.of(context)!.wallets_add, fontWeight: FontWeight.w600),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context, Wallet wallet, LinearGradient gradient) {
    return GestureDetector(
      onLongPress: () {
        context.read<WalletBloc>().add(DeleteWalletEvent(wallet.id));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
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
                    AppText(wallet.name, fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
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
                          _currencyFormat.format(wallet.balance),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const AppText('VISA', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    String name = '';
    double balance = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            left: 24,
            right: 24,
            top: 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: AppText(AppLocalizations.of(context)!.wallets_add, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background(context),
                  borderRadius: BorderRadius.circular(16),
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
                decoration: BoxDecoration(
                  color: AppColors.background(context),
                  borderRadius: BorderRadius.circular(16),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (name.isNotEmpty) {
                      final newWallet = Wallet(
                        id: '', 
                        userId: user.uid,
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
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: AppText(AppLocalizations.of(context)!.wallets_add, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
