// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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

  @override
  String get otp_title => 'Enter OTP';

  @override
  String get otp_subtitle =>
      'We have sent a 6-digit verification code to your phone.';
}
