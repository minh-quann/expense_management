import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @login_dont_have_account.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa có tài khoản?'**
  String get login_dont_have_account;

  /// No description provided for @login_get_started.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu'**
  String get login_get_started;

  /// No description provided for @login_app_name.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý chi tiêu'**
  String get login_app_name;

  /// No description provided for @login_welcome_back.
  ///
  /// In vi, this message translates to:
  /// **'Chào mừng trở lại'**
  String get login_welcome_back;

  /// No description provided for @login_enter_details.
  ///
  /// In vi, this message translates to:
  /// **'Nhập thông tin của bạn bên dưới'**
  String get login_enter_details;

  /// No description provided for @login_phone_label.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại'**
  String get login_phone_label;

  /// No description provided for @login_phone_hint.
  ///
  /// In vi, this message translates to:
  /// **'+84 123 456 789'**
  String get login_phone_hint;

  /// No description provided for @login_sign_in_btn.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get login_sign_in_btn;

  /// No description provided for @login_or_sign_in_with.
  ///
  /// In vi, this message translates to:
  /// **'Hoặc đăng nhập bằng'**
  String get login_or_sign_in_with;

  /// No description provided for @login_google.
  ///
  /// In vi, this message translates to:
  /// **'Google'**
  String get login_google;

  /// No description provided for @login_facebook.
  ///
  /// In vi, this message translates to:
  /// **'Facebook'**
  String get login_facebook;

  /// No description provided for @otp_title.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mã OTP'**
  String get otp_title;

  /// No description provided for @otp_subtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chúng tôi đã gửi mã xác nhận 6 số đến điện thoại của bạn.'**
  String get otp_subtitle;

  /// No description provided for @profile_title.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ'**
  String get profile_title;

  /// No description provided for @profile_account_info.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin tài khoản'**
  String get profile_account_info;

  /// No description provided for @profile_security_code.
  ///
  /// In vi, this message translates to:
  /// **'Mã bảo mật'**
  String get profile_security_code;

  /// No description provided for @profile_privacy_policy.
  ///
  /// In vi, this message translates to:
  /// **'Chính sách bảo mật'**
  String get profile_privacy_policy;

  /// No description provided for @profile_settings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get profile_settings;

  /// No description provided for @profile_logout.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get profile_logout;

  /// No description provided for @profile_logout_confirm.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?'**
  String get profile_logout_confirm;

  /// No description provided for @profile_cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get profile_cancel;

  /// No description provided for @nav_home.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get nav_home;

  /// No description provided for @nav_transactions.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch'**
  String get nav_transactions;

  /// No description provided for @nav_stats.
  ///
  /// In vi, this message translates to:
  /// **'Thống kê'**
  String get nav_stats;

  /// No description provided for @nav_account.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản'**
  String get nav_account;

  /// No description provided for @home_title.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get home_title;

  /// No description provided for @home_total_balance.
  ///
  /// In vi, this message translates to:
  /// **'Tổng số dư'**
  String get home_total_balance;

  /// No description provided for @home_income.
  ///
  /// In vi, this message translates to:
  /// **'Thu nhập'**
  String get home_income;

  /// No description provided for @home_expenses.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiêu'**
  String get home_expenses;

  /// No description provided for @home_transactions.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch'**
  String get home_transactions;

  /// No description provided for @home_see_all.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get home_see_all;

  /// No description provided for @transactions_title.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch'**
  String get transactions_title;

  /// No description provided for @transactions_filter_all.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get transactions_filter_all;

  /// No description provided for @transactions_filter_expense.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiêu'**
  String get transactions_filter_expense;

  /// No description provided for @transactions_filter_income.
  ///
  /// In vi, this message translates to:
  /// **'Thu nhập'**
  String get transactions_filter_income;

  /// No description provided for @transactions_filter_transfer.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển khoản'**
  String get transactions_filter_transfer;

  /// No description provided for @transactions_today.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get transactions_today;

  /// No description provided for @transactions_yesterday.
  ///
  /// In vi, this message translates to:
  /// **'Hôm qua'**
  String get transactions_yesterday;

  /// No description provided for @add_transaction_title.
  ///
  /// In vi, this message translates to:
  /// **'Thêm giao dịch mới'**
  String get add_transaction_title;

  /// No description provided for @add_transaction_expense.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiêu'**
  String get add_transaction_expense;

  /// No description provided for @add_transaction_income.
  ///
  /// In vi, this message translates to:
  /// **'Thu nhập'**
  String get add_transaction_income;

  /// No description provided for @add_transaction_transfer.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển khoản'**
  String get add_transaction_transfer;

  /// No description provided for @add_transaction_amount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền'**
  String get add_transaction_amount;

  /// No description provided for @add_transaction_category.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục'**
  String get add_transaction_category;

  /// No description provided for @add_transaction_wallet.
  ///
  /// In vi, this message translates to:
  /// **'Ví'**
  String get add_transaction_wallet;

  /// No description provided for @add_transaction_source_wallet.
  ///
  /// In vi, this message translates to:
  /// **'Ví nguồn'**
  String get add_transaction_source_wallet;

  /// No description provided for @add_transaction_destination_wallet.
  ///
  /// In vi, this message translates to:
  /// **'Ví đích'**
  String get add_transaction_destination_wallet;

  /// No description provided for @add_transaction_date.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get add_transaction_date;

  /// No description provided for @add_transaction_note_hint.
  ///
  /// In vi, this message translates to:
  /// **'Thêm ghi chú...'**
  String get add_transaction_note_hint;

  /// No description provided for @add_transaction_save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu giao dịch'**
  String get add_transaction_save;

  /// No description provided for @wallets_title.
  ///
  /// In vi, this message translates to:
  /// **'Ví của tôi'**
  String get wallets_title;

  /// No description provided for @wallets_total_assets.
  ///
  /// In vi, this message translates to:
  /// **'Tổng tài sản'**
  String get wallets_total_assets;

  /// No description provided for @wallets_add.
  ///
  /// In vi, this message translates to:
  /// **'Thêm ví'**
  String get wallets_add;

  /// No description provided for @wallets_cash.
  ///
  /// In vi, this message translates to:
  /// **'Tiền mặt'**
  String get wallets_cash;

  /// No description provided for @wallets_bank.
  ///
  /// In vi, this message translates to:
  /// **'Ngân hàng'**
  String get wallets_bank;

  /// No description provided for @wallets_ewallet.
  ///
  /// In vi, this message translates to:
  /// **'Ví điện tử'**
  String get wallets_ewallet;

  /// No description provided for @wallets_credit_card.
  ///
  /// In vi, this message translates to:
  /// **'Thẻ tín dụng'**
  String get wallets_credit_card;

  /// No description provided for @stats_title.
  ///
  /// In vi, this message translates to:
  /// **'Thống kê'**
  String get stats_title;

  /// No description provided for @stats_overview.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quan'**
  String get stats_overview;

  /// No description provided for @stats_expense_chart.
  ///
  /// In vi, this message translates to:
  /// **'Biểu đồ chi tiêu'**
  String get stats_expense_chart;

  /// No description provided for @stats_income_chart.
  ///
  /// In vi, this message translates to:
  /// **'Biểu đồ thu nhập'**
  String get stats_income_chart;

  /// No description provided for @stats_top_spending.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiêu nhiều nhất'**
  String get stats_top_spending;

  /// No description provided for @stats_this_month.
  ///
  /// In vi, this message translates to:
  /// **'Tháng này'**
  String get stats_this_month;

  /// No description provided for @stats_last_month.
  ///
  /// In vi, this message translates to:
  /// **'Tháng trước'**
  String get stats_last_month;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
