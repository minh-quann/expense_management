import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_management/features/home/presentation/home_screen.dart';
import 'package:expense_management/features/auth/presentation/screens/login_screen.dart';
import 'package:expense_management/features/auth/presentation/screens/otp_screen.dart';
import 'package:expense_management/core/routing/app_shell.dart';
import 'package:expense_management/shared/widgets/placeholder_screen.dart';
import 'package:expense_management/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:expense_management/features/settings/presentation/screens/profile_screen.dart';
import 'package:expense_management/features/wallets/presentation/screens/wallets_screen.dart';
import 'package:expense_management/features/transactions/presentation/screens/add_transaction_screen.dart';
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  initialLocation: FirebaseAuth.instance.currentUser != null ? '/' : '/login',
  navigatorKey: _rootNavigatorKey,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
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
              builder: (context, state) => const PlaceholderScreen(title: 'Thống kê'),
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
  ],
);
