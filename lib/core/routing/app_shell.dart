import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/core/utils/auth_token_manager.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_bloc.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_event.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_state.dart';

class AppShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final userId = AuthTokenManager.getUserId();
    if (userId.isNotEmpty) {
      context.read<WalletBloc>().add(LoadWalletsEvent(userId));
      context.read<TransactionBloc>().add(LoadTransactions(userId));
    }
  }

  void _onTap(BuildContext context, int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final userId = AuthTokenManager.getUserId();
    
    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionLoaded && userId.isNotEmpty) {
          context.read<WalletBloc>().add(LoadWalletsEvent(userId));
        }
      },
      child: Scaffold(
        extendBody: true, // Allow body to extend behind the floating nav bar
        body: Stack(
          children: [
            // The main content
            widget.navigationShell,
            
            // Floating Glassmorphism Navigation Bar
            Positioned(
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    height: 72,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? const Color(0xFF1C1C1E).withValues(alpha: 0.75) 
                          : Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: isDark 
                            ? Colors.white.withValues(alpha: 0.1) 
                            : Colors.black.withValues(alpha: 0.05),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(context, 0, Icons.home_outlined, Icons.home, AppLocalizations.of(context)!.nav_home),
                        _buildNavItem(context, 1, Icons.receipt_long_outlined, Icons.receipt_long, AppLocalizations.of(context)!.nav_transactions),
                        _buildAddButton(context),
                        _buildNavItem(context, 2, Icons.pie_chart_outline, Icons.pie_chart, AppLocalizations.of(context)!.nav_stats),
                        _buildNavItem(context, 3, Icons.person_outline, Icons.person, AppLocalizations.of(context)!.nav_account),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/add-transaction'),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = widget.navigationShell.currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.textSecondary(context);

    return GestureDetector(
      onTap: () => _onTap(context, index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withValues(alpha: 0.1) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontFamily: 'Inter',
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
