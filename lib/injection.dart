import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Network
import 'package:expense_management/core/network/api_client.dart';

// Auth
import 'package:expense_management/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:expense_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:expense_management/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:expense_management/features/auth/domain/usecases/login_usecase.dart';
import 'package:expense_management/features/auth/domain/usecases/register_usecase.dart';
import 'package:expense_management/features/auth/domain/usecases/google_login_usecase.dart';
import 'package:expense_management/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:expense_management/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:expense_management/features/auth/domain/usecases/logout_usecase.dart';
import 'package:expense_management/features/auth/presentation/bloc/auth_bloc.dart';

// Wallets
import 'package:expense_management/features/wallets/data/datasources/wallet_remote_datasource.dart';
import 'package:expense_management/features/wallets/domain/repositories/wallet_repository.dart';
import 'package:expense_management/features/wallets/data/repositories/wallet_repository_impl.dart';
import 'package:expense_management/features/wallets/domain/usecases/get_wallets_usecase.dart';
import 'package:expense_management/features/wallets/domain/usecases/add_wallet_usecase.dart';
import 'package:expense_management/features/wallets/domain/usecases/update_wallet_usecase.dart';
import 'package:expense_management/features/wallets/domain/usecases/delete_wallet_usecase.dart';
import 'package:expense_management/features/wallets/domain/usecases/toggle_favorite_wallet_usecase.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_bloc.dart';

// Transactions
import 'package:expense_management/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:expense_management/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:expense_management/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:expense_management/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:expense_management/features/transactions/domain/usecases/get_transactions_by_wallet_usecase.dart';
import 'package:expense_management/features/transactions/domain/usecases/add_transaction_usecase.dart';
import 'package:expense_management/features/transactions/domain/usecases/update_transaction_usecase.dart';
import 'package:expense_management/features/transactions/domain/usecases/delete_transaction_usecase.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_bloc.dart';

// Categories
import 'package:expense_management/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:expense_management/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_management/features/categories/data/repositories/category_repository_impl.dart';
import 'package:expense_management/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:expense_management/features/categories/domain/usecases/add_category_usecase.dart';
import 'package:expense_management/features/categories/domain/usecases/update_category_usecase.dart';
import 'package:expense_management/features/categories/domain/usecases/delete_category_usecase.dart';
import 'package:expense_management/features/categories/domain/usecases/seed_default_categories_usecase.dart';
import 'package:expense_management/features/categories/presentation/bloc/category_bloc.dart';

// Budgets
import 'package:expense_management/features/budgets/data/datasources/budget_local_datasource.dart';
import 'package:expense_management/features/budgets/domain/repositories/budget_repository.dart';
import 'package:expense_management/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:expense_management/features/budgets/domain/usecases/get_budgets_usecase.dart';
import 'package:expense_management/features/budgets/domain/usecases/add_budget_usecase.dart';
import 'package:expense_management/features/budgets/domain/usecases/update_budget_usecase.dart';
import 'package:expense_management/features/budgets/domain/usecases/delete_budget_usecase.dart';
import 'package:expense_management/features/budgets/presentation/bloc/budget_bloc.dart';

// Goals
import 'package:expense_management/features/goals/data/datasources/goal_local_datasource.dart';
import 'package:expense_management/features/goals/domain/repositories/goal_repository.dart';
import 'package:expense_management/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:expense_management/features/goals/domain/usecases/get_goals_usecase.dart';
import 'package:expense_management/features/goals/domain/usecases/add_goal_usecase.dart';
import 'package:expense_management/features/goals/domain/usecases/update_goal_usecase.dart';
import 'package:expense_management/features/goals/domain/usecases/delete_goal_usecase.dart';
import 'package:expense_management/features/goals/domain/usecases/add_funds_to_goal_usecase.dart';
import 'package:expense_management/features/goals/presentation/bloc/goal_bloc.dart';

// Recurring
import 'package:expense_management/features/recurring/data/datasources/recurring_local_datasource.dart';
import 'package:expense_management/features/recurring/domain/repositories/recurring_repository.dart';
import 'package:expense_management/features/recurring/data/repositories/recurring_repository_impl.dart';
import 'package:expense_management/features/recurring/domain/usecases/get_recurrings_usecase.dart';
import 'package:expense_management/features/recurring/domain/usecases/add_recurring_usecase.dart';
import 'package:expense_management/features/recurring/domain/usecases/update_recurring_usecase.dart';
import 'package:expense_management/features/recurring/domain/usecases/delete_recurring_usecase.dart';
import 'package:expense_management/features/recurring/presentation/bloc/recurring_bloc.dart';

// Stats
import 'package:expense_management/features/stats/data/datasources/stats_remote_datasource.dart';
import 'package:expense_management/features/stats/domain/repositories/stats_repository.dart';
import 'package:expense_management/features/stats/data/repositories/stats_repository_impl.dart';
import 'package:expense_management/features/stats/domain/usecases/get_stats_usecase.dart';
import 'package:expense_management/features/stats/presentation/bloc/stats_bloc.dart';

// Profile/Settings
import 'package:expense_management/features/settings/data/datasources/profile_remote_datasource.dart';
import 'package:expense_management/features/settings/domain/repositories/profile_repository.dart';
import 'package:expense_management/features/settings/data/repositories/profile_repository_impl.dart';
import 'package:expense_management/features/settings/domain/usecases/get_profile_usecase.dart';
import 'package:expense_management/features/settings/domain/usecases/update_profile_usecase.dart';
import 'package:expense_management/features/settings/domain/usecases/upload_avatar_usecase.dart';
import 'package:expense_management/features/settings/presentation/bloc/profile_bloc.dart';

// App Lock
import 'package:expense_management/features/app_lock/data/services/app_lock_service.dart';
import 'package:expense_management/features/app_lock/domain/repositories/app_lock_repository.dart';
import 'package:expense_management/features/app_lock/data/repositories/app_lock_repository_impl.dart';
import 'package:expense_management/features/app_lock/domain/usecases/save_pin_usecase.dart';
import 'package:expense_management/features/app_lock/domain/usecases/get_pin_usecase.dart';
import 'package:expense_management/features/app_lock/domain/usecases/verify_pin_usecase.dart';
import 'package:expense_management/features/app_lock/domain/usecases/remove_pin_usecase.dart';
import 'package:expense_management/features/app_lock/domain/usecases/get_security_question_usecase.dart';
import 'package:expense_management/features/app_lock/domain/usecases/reset_pin_usecase.dart';
import 'package:expense_management/features/app_lock/domain/usecases/is_lock_enabled_usecase.dart';
import 'package:expense_management/features/app_lock/domain/usecases/sync_lock_state_usecase.dart';
import 'package:expense_management/features/app_lock/domain/usecases/is_biometric_enabled_usecase.dart';
import 'package:expense_management/features/app_lock/domain/usecases/set_biometric_enabled_usecase.dart';
import 'package:expense_management/features/app_lock/domain/usecases/is_biometric_available_usecase.dart';
import 'package:expense_management/features/app_lock/domain/usecases/get_available_biometrics_usecase.dart';
import 'package:expense_management/features/app_lock/domain/usecases/authenticate_with_biometrics_usecase.dart';
import 'package:expense_management/features/app_lock/presentation/bloc/app_lock_bloc.dart';

final getIt = GetIt.instance;

Future<void> initInjection() async {
  // ==========================================
  // Core / External Dependencies
  // ==========================================
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  getIt.registerLazySingleton<LocalAuthentication>(() => LocalAuthentication());
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // ==========================================
  // Feature: App Lock
  // ==========================================
  // Repository & Service
  getIt.registerLazySingleton<AppLockRepository>(() => AppLockRepositoryImpl(
        secureStorage: getIt<FlutterSecureStorage>(),
        localAuth: getIt<LocalAuthentication>(),
      ));
  getIt.registerLazySingleton<AppLockService>(() => AppLockService(
        repository: getIt<AppLockRepository>(),
      ));

  // UseCases
  getIt.registerLazySingleton<SavePinUseCase>(() => SavePinUseCase(getIt<AppLockRepository>()));
  getIt.registerLazySingleton<GetPinUseCase>(() => GetPinUseCase(getIt<AppLockRepository>()));
  getIt.registerLazySingleton<VerifyPinUseCase>(() => VerifyPinUseCase(getIt<AppLockRepository>()));
  getIt.registerLazySingleton<RemovePinUseCase>(() => RemovePinUseCase(getIt<AppLockRepository>()));
  getIt.registerLazySingleton<GetSecurityQuestionUseCase>(() => GetSecurityQuestionUseCase(getIt<AppLockRepository>()));
  getIt.registerLazySingleton<ResetPinUseCase>(() => ResetPinUseCase(getIt<AppLockRepository>()));
  getIt.registerLazySingleton<IsLockEnabledUseCase>(() => IsLockEnabledUseCase(getIt<AppLockRepository>()));
  getIt.registerLazySingleton<SyncLockStateUseCase>(() => SyncLockStateUseCase(getIt<AppLockRepository>()));
  getIt.registerLazySingleton<IsBiometricEnabledUseCase>(() => IsBiometricEnabledUseCase(getIt<AppLockRepository>()));
  getIt.registerLazySingleton<SetBiometricEnabledUseCase>(() => SetBiometricEnabledUseCase(getIt<AppLockRepository>()));
  getIt.registerLazySingleton<IsBiometricAvailableUseCase>(() => IsBiometricAvailableUseCase(getIt<AppLockRepository>()));
  getIt.registerLazySingleton<GetAvailableBiometricsUseCase>(() => GetAvailableBiometricsUseCase(getIt<AppLockRepository>()));
  getIt.registerLazySingleton<AuthenticateWithBiometricsUseCase>(() => AuthenticateWithBiometricsUseCase(getIt<AppLockRepository>()));

  // BLoC
  getIt.registerFactory<AppLockBloc>(() => AppLockBloc(
        repository: getIt<AppLockRepository>(),
        isLockEnabledUseCase: getIt<IsLockEnabledUseCase>(),
        isBiometricAvailableUseCase: getIt<IsBiometricAvailableUseCase>(),
        isBiometricEnabledUseCase: getIt<IsBiometricEnabledUseCase>(),
        verifyPinUseCase: getIt<VerifyPinUseCase>(),
        authenticateWithBiometricsUseCase: getIt<AuthenticateWithBiometricsUseCase>(),
        removePinUseCase: getIt<RemovePinUseCase>(),
        setBiometricEnabledUseCase: getIt<SetBiometricEnabledUseCase>(),
        savePinUseCase: getIt<SavePinUseCase>(),
        resetPinUseCase: getIt<ResetPinUseCase>(),
      ));

  // ==========================================
  // Feature: Auth
  // ==========================================
  // DataSource & Repository
  getIt.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(
        dio: getIt<ApiClient>().dio,
      ));
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
        remoteDataSource: getIt<AuthRemoteDataSource>(),
        appLockService: getIt<AppLockService>(),
      ));

  // UseCases
  getIt.registerLazySingleton<LoginUseCase>(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<GoogleLoginUseCase>(() => GoogleLoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<ForgotPasswordUseCase>(() => ForgotPasswordUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<ResetPasswordUseCase>(() => ResetPasswordUseCase(getIt<AuthRepository>()));

  // BLoC
  getIt.registerFactory<AuthBloc>(() => AuthBloc(
        auth: getIt<FirebaseAuth>(),
        loginUseCase: getIt<LoginUseCase>(),
        registerUseCase: getIt<RegisterUseCase>(),
        googleLoginUseCase: getIt<GoogleLoginUseCase>(),
        logoutUseCase: getIt<LogoutUseCase>(),
        forgotPasswordUseCase: getIt<ForgotPasswordUseCase>(),
        resetPasswordUseCase: getIt<ResetPasswordUseCase>(),
      ));

  // ==========================================
  // Feature: Wallets
  // ==========================================
  // DataSource & Repository
  getIt.registerLazySingleton<WalletRemoteDataSource>(() => WalletRemoteDataSourceImpl(
        apiClient: getIt<ApiClient>(),
      ));
  getIt.registerLazySingleton<WalletRepository>(() => WalletRepositoryImpl.withDataSource(
        getIt<WalletRemoteDataSource>(),
      ));

  // UseCases
  getIt.registerLazySingleton<GetWalletsUseCase>(() => GetWalletsUseCase(getIt<WalletRepository>()));
  getIt.registerLazySingleton<AddWalletUseCase>(() => AddWalletUseCase(getIt<WalletRepository>()));
  getIt.registerLazySingleton<UpdateWalletUseCase>(() => UpdateWalletUseCase(getIt<WalletRepository>()));
  getIt.registerLazySingleton<DeleteWalletUseCase>(() => DeleteWalletUseCase(getIt<WalletRepository>()));
  getIt.registerLazySingleton<ToggleFavoriteWalletUseCase>(() => ToggleFavoriteWalletUseCase(getIt<WalletRepository>()));

  // BLoC
  getIt.registerFactory<WalletBloc>(() => WalletBloc(
        repository: getIt<WalletRepository>(),
        getWalletsUseCase: getIt<GetWalletsUseCase>(),
        addWalletUseCase: getIt<AddWalletUseCase>(),
        updateWalletUseCase: getIt<UpdateWalletUseCase>(),
        deleteWalletUseCase: getIt<DeleteWalletUseCase>(),
        toggleFavoriteWalletUseCase: getIt<ToggleFavoriteWalletUseCase>(),
      ));

  // ==========================================
  // Feature: Transactions
  // ==========================================
  // DataSource & Repository
  getIt.registerLazySingleton<TransactionRemoteDataSource>(() => TransactionRemoteDataSourceImpl(
        apiClient: getIt<ApiClient>(),
      ));
  getIt.registerLazySingleton<TransactionRepository>(() => TransactionRepositoryImpl.withDataSource(
        getIt<TransactionRemoteDataSource>(),
      ));

  // UseCases
  getIt.registerLazySingleton<GetTransactionsUseCase>(() => GetTransactionsUseCase(getIt<TransactionRepository>()));
  getIt.registerLazySingleton<GetTransactionsByWalletUseCase>(() => GetTransactionsByWalletUseCase(getIt<TransactionRepository>()));
  getIt.registerLazySingleton<AddTransactionUseCase>(() => AddTransactionUseCase(getIt<TransactionRepository>()));
  getIt.registerLazySingleton<UpdateTransactionUseCase>(() => UpdateTransactionUseCase(getIt<TransactionRepository>()));
  getIt.registerLazySingleton<DeleteTransactionUseCase>(() => DeleteTransactionUseCase(getIt<TransactionRepository>()));

  // BLoC
  getIt.registerFactory<TransactionBloc>(() => TransactionBloc(
        repository: getIt<TransactionRepository>(),
        getTransactionsUseCase: getIt<GetTransactionsUseCase>(),
        addTransactionUseCase: getIt<AddTransactionUseCase>(),
        updateTransactionUseCase: getIt<UpdateTransactionUseCase>(),
        deleteTransactionUseCase: getIt<DeleteTransactionUseCase>(),
      ));

  // ==========================================
  // Feature: Categories
  // ==========================================
  // DataSource & Repository
  getIt.registerLazySingleton<CategoryRemoteDataSource>(() => CategoryRemoteDataSourceImpl(
        apiClient: getIt<ApiClient>(),
      ));
  getIt.registerLazySingleton<CategoryRepository>(() => CategoryRepositoryImpl.withDataSource(
        getIt<CategoryRemoteDataSource>(),
      ));

  // UseCases
  getIt.registerLazySingleton<GetCategoriesUseCase>(() => GetCategoriesUseCase(getIt<CategoryRepository>()));
  getIt.registerLazySingleton<AddCategoryUseCase>(() => AddCategoryUseCase(getIt<CategoryRepository>()));
  getIt.registerLazySingleton<UpdateCategoryUseCase>(() => UpdateCategoryUseCase(getIt<CategoryRepository>()));
  getIt.registerLazySingleton<DeleteCategoryUseCase>(() => DeleteCategoryUseCase(getIt<CategoryRepository>()));
  getIt.registerLazySingleton<SeedDefaultCategoriesUseCase>(() => SeedDefaultCategoriesUseCase(getIt<CategoryRepository>()));

  // BLoC
  getIt.registerFactory<CategoryBloc>(() => CategoryBloc(
        repository: getIt<CategoryRepository>(),
        getCategoriesUseCase: getIt<GetCategoriesUseCase>(),
        addCategoryUseCase: getIt<AddCategoryUseCase>(),
        updateCategoryUseCase: getIt<UpdateCategoryUseCase>(),
        deleteCategoryUseCase: getIt<DeleteCategoryUseCase>(),
        seedDefaultCategoriesUseCase: getIt<SeedDefaultCategoriesUseCase>(),
      ));

  // ==========================================
  // Feature: Budgets
  // ==========================================
  // DataSource & Repository
  getIt.registerLazySingleton<BudgetLocalDataSource>(() => BudgetLocalDataSourceImpl());
  getIt.registerLazySingleton<BudgetRepository>(() => BudgetRepositoryImpl.withDataSource(
        getIt<BudgetLocalDataSource>(),
      ));

  // UseCases
  getIt.registerLazySingleton<GetBudgetsUseCase>(() => GetBudgetsUseCase(getIt<BudgetRepository>()));
  getIt.registerLazySingleton<AddBudgetUseCase>(() => AddBudgetUseCase(getIt<BudgetRepository>()));
  getIt.registerLazySingleton<UpdateBudgetUseCase>(() => UpdateBudgetUseCase(getIt<BudgetRepository>()));
  getIt.registerLazySingleton<DeleteBudgetUseCase>(() => DeleteBudgetUseCase(getIt<BudgetRepository>()));

  // BLoC
  getIt.registerFactory<BudgetBloc>(() => BudgetBloc(
        repository: getIt<BudgetRepository>(),
        getBudgetsUseCase: getIt<GetBudgetsUseCase>(),
        addBudgetUseCase: getIt<AddBudgetUseCase>(),
        updateBudgetUseCase: getIt<UpdateBudgetUseCase>(),
        deleteBudgetUseCase: getIt<DeleteBudgetUseCase>(),
      ));

  // ==========================================
  // Feature: Goals
  // ==========================================
  // DataSource & Repository
  getIt.registerLazySingleton<GoalLocalDataSource>(() => GoalLocalDataSourceImpl());
  getIt.registerLazySingleton<GoalRepository>(() => GoalRepositoryImpl.withDataSource(
        getIt<GoalLocalDataSource>(),
      ));

  // UseCases
  getIt.registerLazySingleton<GetGoalsUseCase>(() => GetGoalsUseCase(getIt<GoalRepository>()));
  getIt.registerLazySingleton<AddGoalUseCase>(() => AddGoalUseCase(getIt<GoalRepository>()));
  getIt.registerLazySingleton<UpdateGoalUseCase>(() => UpdateGoalUseCase(getIt<GoalRepository>()));
  getIt.registerLazySingleton<DeleteGoalUseCase>(() => DeleteGoalUseCase(getIt<GoalRepository>()));
  getIt.registerLazySingleton<AddFundsToGoalUseCase>(() => AddFundsToGoalUseCase(getIt<GoalRepository>()));

  // BLoC
  getIt.registerFactory<GoalBloc>(() => GoalBloc(
        repository: getIt<GoalRepository>(),
        getGoalsUseCase: getIt<GetGoalsUseCase>(),
        addGoalUseCase: getIt<AddGoalUseCase>(),
        updateGoalUseCase: getIt<UpdateGoalUseCase>(),
        deleteGoalUseCase: getIt<DeleteGoalUseCase>(),
        addFundsToGoalUseCase: getIt<AddFundsToGoalUseCase>(),
      ));

  // ==========================================
  // Feature: Recurring
  // ==========================================
  // DataSource & Repository
  getIt.registerLazySingleton<RecurringLocalDataSource>(() => RecurringLocalDataSourceImpl());
  getIt.registerLazySingleton<RecurringRepository>(() => RecurringRepositoryImpl.withDataSource(
        getIt<RecurringLocalDataSource>(),
      ));

  // UseCases
  getIt.registerLazySingleton<GetRecurringsUseCase>(() => GetRecurringsUseCase(getIt<RecurringRepository>()));
  getIt.registerLazySingleton<AddRecurringUseCase>(() => AddRecurringUseCase(getIt<RecurringRepository>()));
  getIt.registerLazySingleton<UpdateRecurringUseCase>(() => UpdateRecurringUseCase(getIt<RecurringRepository>()));
  getIt.registerLazySingleton<DeleteRecurringUseCase>(() => DeleteRecurringUseCase(getIt<RecurringRepository>()));

  // BLoC
  getIt.registerFactory<RecurringBloc>(() => RecurringBloc(
        repository: getIt<RecurringRepository>(),
        getRecurringsUseCase: getIt<GetRecurringsUseCase>(),
        addRecurringUseCase: getIt<AddRecurringUseCase>(),
        updateRecurringUseCase: getIt<UpdateRecurringUseCase>(),
        deleteRecurringUseCase: getIt<DeleteRecurringUseCase>(),
      ));

  // ==========================================
  // Feature: Stats
  // ==========================================
  // DataSource & Repository
  getIt.registerLazySingleton<StatsRemoteDataSource>(() => StatsRemoteDataSourceImpl(
        apiClient: getIt<ApiClient>(),
      ));
  getIt.registerLazySingleton<StatsRepository>(() => StatsRepositoryImpl.withDataSource(
        getIt<StatsRemoteDataSource>(),
      ));

  // UseCases
  getIt.registerLazySingleton<GetStatsUseCase>(() => GetStatsUseCase(getIt<StatsRepository>()));

  // BLoC
  getIt.registerFactory<StatsBloc>(() => StatsBloc(
        statsRepository: getIt<StatsRepository>(),
        getStatsUseCase: getIt<GetStatsUseCase>(),
      ));

  // ==========================================
  // Feature: Profile/Settings
  // ==========================================
  // DataSource & Repository
  getIt.registerLazySingleton<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl(
        apiClient: getIt<ApiClient>(),
      ));
  getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl.withDataSource(
        getIt<ProfileRemoteDataSource>(),
      ));

  // UseCases
  getIt.registerLazySingleton<GetProfileUseCase>(() => GetProfileUseCase(getIt<ProfileRepository>()));
  getIt.registerLazySingleton<UpdateProfileUseCase>(() => UpdateProfileUseCase(getIt<ProfileRepository>()));
  getIt.registerLazySingleton<UploadAvatarUseCase>(() => UploadAvatarUseCase(getIt<ProfileRepository>()));

  // BLoC
  getIt.registerFactory<ProfileBloc>(() => ProfileBloc(
        getIt<ProfileRepository>(),
        getProfileUseCase: getIt<GetProfileUseCase>(),
        updateProfileUseCase: getIt<UpdateProfileUseCase>(),
        uploadAvatarUseCase: getIt<UploadAvatarUseCase>(),
      ));
}
