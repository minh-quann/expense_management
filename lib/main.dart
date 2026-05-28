import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'package:expense_management/firebase_options.dart';
import 'package:expense_management/injection.dart';
import 'package:expense_management/core/routing/app_router.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/core/localization/locale_cubit.dart';
import 'package:expense_management/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_bloc.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:expense_management/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_management/features/budgets/presentation/bloc/budget_bloc.dart';
import 'package:expense_management/features/goals/presentation/bloc/goal_bloc.dart';
import 'package:expense_management/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:expense_management/core/utils/auth_token_manager.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/features/app_lock/presentation/bloc/app_lock_bloc.dart';
import 'package:expense_management/features/app_lock/presentation/widgets/app_lock_wrapper.dart';
import 'package:expense_management/features/stats/presentation/bloc/stats_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable edge-to-edge display on Android
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await AuthTokenManager.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Dependency Injection
  await initInjection();

  // Pre-warm glass shaders to avoid first-frame white flash
  await LiquidGlassWidgets.initialize();

  runApp(
    LiquidGlassWidgets.wrap(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AppLockBloc>(
            create: (context) => getIt<AppLockBloc>(),
          ),
          BlocProvider<AuthBloc>(
            create: (context) => getIt<AuthBloc>(),
          ),
          BlocProvider<LocaleCubit>(
            create: (context) => LocaleCubit(),
          ),
          BlocProvider<WalletBloc>(
            create: (context) => getIt<WalletBloc>(),
          ),
          BlocProvider<TransactionBloc>(
            create: (context) => getIt<TransactionBloc>(),
          ),
          BlocProvider<CategoryBloc>(
            create: (context) => getIt<CategoryBloc>(),
          ),
          BlocProvider<BudgetBloc>(
            create: (context) => getIt<BudgetBloc>(),
          ),
          BlocProvider<GoalBloc>(
            create: (context) => getIt<GoalBloc>(),
          ),
          BlocProvider<RecurringBloc>(
            create: (context) => getIt<RecurringBloc>(),
          ),
          BlocProvider<StatsBloc>(
            create: (context) => getIt<StatsBloc>(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return ToastificationWrapper(
          child: MaterialApp.router(
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
              scaffoldBackgroundColor: AppColors.appBackgroundLight,
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
                child: AppLockWrapper(
                  child: child ?? const SizedBox(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

