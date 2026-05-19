// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  // --- Login ---
  @override
  String get login_dont_have_account => 'Don\'t have an account?';
  @override
  String get login_get_started => 'Get Started';
  @override
  String get login_app_name => 'Expense App';
  @override
  String get login_welcome_back => 'Welcome Back';
  @override
  String get login_enter_details => 'Enter your details below';
  @override
  String get login_phone_label => 'Phone Number';
  @override
  String get login_phone_hint => '+1 234 567 8900';
  @override
  String get login_sign_in_btn => 'Sign in';
  @override
  String get login_or_sign_in_with => 'Or sign in with';
  @override
  String get login_google => 'Google';
  @override
  String get login_facebook => 'Facebook';

  // --- OTP ---
  @override
  String get otp_title => 'Enter OTP';
  @override
  String get otp_subtitle =>
      'We have sent a 6-digit verification code to your phone.';

  // --- Profile ---
  @override
  String get profile_title => 'Profile';
  @override
  String get profile_account_info => 'Account Info';
  @override
  String get profile_security_code => 'Security Code';
  @override
  String get profile_privacy_policy => 'Privacy Policy';
  @override
  String get profile_settings => 'Settings';
  @override
  String get profile_logout => 'Logout';
  @override
  String get profile_logout_confirm =>
      'Are you sure you want to log out of the application?';
  @override
  String get profile_cancel => 'Cancel';

  // --- Bottom Navigation ---
  @override
  String get nav_home => 'Home';
  @override
  String get nav_transactions => 'Transactions';
  @override
  String get nav_stats => 'Statistics';
  @override
  String get nav_account => 'Account';

  // --- Home Screen ---
  @override
  String get home_title => 'Home';
  @override
  String get home_total_balance => 'Total Balance';
  @override
  String get home_income => 'Income';
  @override
  String get home_expenses => 'Expenses';
  @override
  String get home_transactions => 'Transactions';
  @override
  String get home_see_all => 'See All';

  // --- Transactions Screen ---
  @override
  String get transactions_title => 'Transactions';
  @override
  String get transactions_filter_all => 'All';
  @override
  String get transactions_filter_expense => 'Expense';
  @override
  String get transactions_filter_income => 'Income';
  @override
  String get transactions_filter_transfer => 'Transfer';
  @override
  String get transactions_today => 'Today';
  @override
  String get transactions_yesterday => 'Yesterday';

  // --- Add Transaction Screen ---
  @override
  String get add_transaction_title => 'New Transaction';
  @override
  String get add_transaction_expense => 'Expense';
  @override
  String get add_transaction_income => 'Income';
  @override
  String get add_transaction_transfer => 'Transfer';
  @override
  String get add_transaction_amount => 'How much?';
  @override
  String get add_transaction_category => 'Category';
  @override
  String get add_transaction_wallet => 'Wallet';
  @override
  String get add_transaction_date => 'Date';
  @override
  String get add_transaction_note_hint => 'Add a note...';
  @override
  String get add_transaction_save => 'Save Transaction';

  // --- Wallets Screen ---
  @override
  String get wallets_title => 'My Wallets';
  @override
  String get wallets_total_assets => 'Total Assets';
  @override
  String get wallets_add => 'Add Wallet';
  @override
  String get wallets_cash => 'Cash';
  @override
  String get wallets_bank => 'Bank';
  @override
  String get wallets_ewallet => 'E-Wallet';
  @override
  String get wallets_credit_card => 'Credit Card';
}
