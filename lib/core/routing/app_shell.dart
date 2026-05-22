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
            
            // Floating Navigation Bar
            Positioned(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 12,
              child: Container(
                height: 64,
                padding: const EdgeInsets.all(4),
                decoration: ShapeDecoration(
                  color: isDark
                      ? const Color(0xFF2C2C2E)
                      : const Color(0xFFF8F8F8),
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final totalWidth = constraints.maxWidth;
                    final currentIndex = widget.navigationShell.currentIndex;
                    // Map nav index (0-3) to slot (0-4), skipping slot 2 (add button)
                    final slot = currentIndex < 2 ? currentIndex : currentIndex + 1;

                    // Selected item is wider, pushes others aside
                    const selectedFlex = 1.2;
                    const normalFlex = 1.0;
                    final totalFlex = 4 * normalFlex + selectedFlex; // 4 normal + 1 selected
                    final normalWidth = totalWidth / totalFlex;
                    final selectedWidth = normalWidth * selectedFlex;

                    // Pill left = sum of all items before selected slot (all normal width)
                    final pillLeft = slot * normalWidth;

                    // Calculate width for each slot
                    double slotWidth(int s) => s == slot ? selectedWidth : normalWidth;

                    return Stack(
                      children: [
                        // Sliding pill indicator
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          left: pillLeft,
                          top: 0,
                          bottom: 0,
                          width: selectedWidth,
                          child: Container(
                            decoration: ShapeDecoration(
                              color: isDark
                                  ? const Color(0xFF3A3A3C)
                                  : const Color(0xFFE5E5E5),
                              shape: RoundedSuperellipseBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                        ),
                        // Nav items row on top
                        Row(
                          children: [
                            _buildNavItem(context, 0, Icons.home_outlined, Icons.home, AppLocalizations.of(context)!.nav_home, slotWidth(0)),
                            _buildNavItem(context, 1, Icons.receipt_long_outlined, Icons.receipt_long, AppLocalizations.of(context)!.nav_transactions, slotWidth(1)),
                            _buildAddItem(context, isDark, slotWidth(2)),
                            _buildNavItem(context, 2, Icons.pie_chart_outline, Icons.pie_chart, AppLocalizations.of(context)!.nav_stats, slotWidth(3)),
                            _buildNavItem(context, 3, Icons.person_outline, Icons.person, AppLocalizations.of(context)!.nav_account, slotWidth(4)),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Center "add" button — styled identically to the other nav items
  Widget _buildAddItem(BuildContext context, bool isDark, double width) {
    final color = isDark ? const Color(0xFF8E8E93) : const Color(0xFF3C3C43);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      width: width,
      child: GestureDetector(
        onTap: () => context.push('/add-transaction'),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                'Thêm',
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, IconData activeIcon, String label, double width) {
    final isSelected = widget.navigationShell.currentIndex == index;
    final isDark = AppColors.isDark(context);
    final color = isSelected
        ? AppColors.primary
        : (isDark ? const Color(0xFF8E8E93) : const Color(0xFF3C3C43));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      width: width,
      child: GestureDetector(
        onTap: () => _onTap(context, index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey(isSelected),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontFamily: 'Inter',
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
