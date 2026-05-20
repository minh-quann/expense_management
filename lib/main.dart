import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:expense_management/firebase_options.dart';
import 'package:expense_management/core/routing/app_router.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/core/localization/locale_cubit.dart';
import 'package:expense_management/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_bloc.dart';
import 'package:expense_management/features/wallets/data/repositories/wallet_repository_impl.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:expense_management/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:expense_management/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_management/features/categories/data/repositories/category_repository_impl.dart';
import 'package:expense_management/features/budgets/presentation/bloc/budget_bloc.dart';
import 'package:expense_management/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:expense_management/features/goals/presentation/bloc/goal_bloc.dart';
import 'package:expense_management/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:expense_management/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:expense_management/features/recurring/data/repositories/recurring_repository_impl.dart';
import 'package:expense_management/core/utils/auth_token_manager.dart';
import 'package:expense_management/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable edge-to-edge display on Android
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await AuthTokenManager.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        BlocProvider<LocaleCubit>(
          create: (context) => LocaleCubit(),
        ),
        BlocProvider<WalletBloc>(
          create: (context) => WalletBloc(
            repository: WalletRepositoryImpl(FirebaseFirestore.instance),
          ),
        ),
        BlocProvider<TransactionBloc>(
          create: (context) => TransactionBloc(
            repository: TransactionRepositoryImpl(FirebaseFirestore.instance),
          ),
        ),
        BlocProvider<CategoryBloc>(
          create: (context) => CategoryBloc(
            repository: CategoryRepositoryImpl(FirebaseFirestore.instance),
          ),
        ),
        BlocProvider<BudgetBloc>(
          create: (context) => BudgetBloc(
            repository: BudgetRepositoryImpl(FirebaseFirestore.instance),
          ),
        ),
        BlocProvider<GoalBloc>(
          create: (context) => GoalBloc(
            repository: GoalRepositoryImpl(FirebaseFirestore.instance),
          ),
        ),
        BlocProvider<RecurringBloc>(
          create: (context) => RecurringBloc(
            repository: RecurringRepositoryImpl(FirebaseFirestore.instance),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return MaterialApp.router(
          title: 'Expense Management',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            fontFamily: 'GoogleSansFlex',
            appBarTheme: const AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark, // Black status bar icons for Android
                statusBarBrightness: Brightness.light,    // Black status bar text/icons for iOS
              ),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF121212),
            fontFamily: 'GoogleSansFlex',
            appBarTheme: const AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light, // White status bar icons for Android
                statusBarBrightness: Brightness.dark,     // White status bar text/icons for iOS
              ),
            ),
          ),
          themeMode: ThemeMode.system, // Always respect system for dark mode
          routerConfig: appRouter,
          builder: (context, child) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
                systemNavigationBarColor: Colors.transparent,
                systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                systemNavigationBarDividerColor: Colors.transparent,
              ),
              child: child ?? const SizedBox(),
            );
          },
        );
      },
    );
  }
}
