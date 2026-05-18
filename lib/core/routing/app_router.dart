import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_management/features/home/presentation/home_screen.dart';
import 'package:expense_management/features/auth/presentation/screens/login_screen.dart';
import 'package:expense_management/features/auth/presentation/screens/otp_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login', // Start with login screen
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
      routes: [
        GoRoute(
          path: 'phone',
          builder: (BuildContext context, GoRouterState state) {
            return const OtpScreen();
          },
        ),
      ],
    ),
  ],
);
