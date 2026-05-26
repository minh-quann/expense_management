import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_cupertino_symbols/flutter_cupertino_symbols.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/core/utils/auth_token_manager.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_bloc.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_event.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_state.dart';
import 'package:expense_management/shared/widgets/app_liquid_glass.dart';
import 'package:expense_management/shared/widgets/app_text.dart';

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
        extendBody: true,
        body: Stack(
          children: [
            widget.navigationShell,

            // Floating Navigation Bar
            Positioned(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 12,
              child: SizedBox(
                height: 64,
                child: AppLiquidGlassIndicator(
                  selectedIndex: widget.navigationShell.currentIndex,
                  count: 4,
                  isDark: isDark,
                  onChanged: (index) {
                    _onTap(context, index);
                  },
                  borderRadius: 100,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildNavItem(
                        0,
                        SFSymbols.house,
                        SFSymbols.house_fill,
                        AppLocalizations.of(context)!.nav_home,
                      ),
                      _buildNavItem(
                        1,
                        SFSymbols.list_clipboard,
                        SFSymbols.list_clipboard_fill,
                        AppLocalizations.of(context)!.nav_transactions,
                      ),
                      _buildNavItem(
                        2,
                        SFSymbols.chart_bar,
                        SFSymbols.chart_bar_fill,
                        AppLocalizations.of(context)!.nav_stats,
                      ),
                      _buildNavItem(
                        3,
                        SFSymbols.person,
                        SFSymbols.person_fill,
                        AppLocalizations.of(context)!.nav_account,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    return Expanded(
      child: Builder(
        builder: (context) {
          final activeIndex = IndicatorStateScope.of(context);
          final isSelected = activeIndex == index;
          final isDark = AppColors.isDark(context);
          final color = isSelected
              ? AppColors.primary
              : (isDark ? const Color(0xFF8E8E93) : const Color(0xFF3C3C43));

          return GestureDetector(
            onTap: () => _onTap(context, index),
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? activeIcon : icon,
                    color: color,
                    size: 24,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    label,
                    color: color,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
