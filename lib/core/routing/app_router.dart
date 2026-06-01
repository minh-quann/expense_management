import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_management/core/utils/auth_token_manager.dart';
import 'package:expense_management/features/home/presentation/home_screen.dart';
import 'package:expense_management/features/auth/presentation/screens/login_screen.dart';
import 'package:expense_management/features/auth/presentation/screens/otp_screen.dart';
import 'package:expense_management/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:expense_management/core/routing/app_shell.dart';
import 'package:expense_management/core/routing/animated_branch_container.dart';
import 'package:expense_management/features/stats/presentation/screens/stats_screen.dart';
import 'package:expense_management/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:expense_management/features/settings/presentation/screens/profile_screen.dart';
import 'package:expense_management/features/wallets/presentation/screens/wallets_screen.dart';
import 'package:expense_management/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:expense_management/features/budgets/presentation/screens/budgets_screen.dart';
import 'package:expense_management/features/goals/presentation/screens/goals_screen.dart';
import 'package:expense_management/features/recurring/presentation/screens/recurring_screen.dart';
import 'package:expense_management/features/categories/presentation/screens/categories_screen.dart';
import 'package:expense_management/features/categories/presentation/screens/add_category_screen.dart';
import 'package:expense_management/features/categories/domain/entities/category.dart';
import 'package:expense_management/features/app_lock/presentation/screens/security_settings_screen.dart';
import 'package:expense_management/features/settings/presentation/screens/general_settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  initialLocation: AuthTokenManager.isLoggedIn() ? '/' : '/login',
  navigatorKey: _rootNavigatorKey,
  routes: [
    StatefulShellRoute(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      navigatorContainerBuilder: (context, navigationShell, children) {
        return AnimatedBranchContainer(
          currentIndex: navigationShell.currentIndex,
          children: children,
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/transactions',
              builder: (context, state) => const TransactionsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/stats',
              builder: (context, state) => const StatsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/account',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/add-transaction',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddTransactionScreen(),
    ),
    GoRoute(
      path: '/wallets',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const WalletsScreen(),
    ),
    GoRoute(
      path: '/budgets',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BudgetsScreen(),
    ),
    GoRoute(
      path: '/goals',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const GoalsScreen(),
    ),
    GoRoute(
      path: '/recurring',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const RecurringScreen(),
    ),
    GoRoute(
      path: '/categories',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CategoriesScreen(),
    ),
    GoRoute(
      path: '/add_category',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final category = state.extra as AppCategory?;
        return AddCategoryScreen(category: category);
      },
    ),
    GoRoute(
      path: '/login',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
      routes: [
        GoRoute(
          path: 'phone',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (BuildContext context, GoRouterState state) {
            return const OtpScreen();
          },
        ),
      ],
    ),
    GoRoute(
      path: '/forgot-password',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const ForgotPasswordScreen();
      },
    ),
    GoRoute(
      path: '/security',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const SecuritySettingsScreen();
      },
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const GeneralSettingsScreen();
      },
    ),
  ],
);
