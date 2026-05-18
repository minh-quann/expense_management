// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get login_dont_have_account => 'Bạn chưa có tài khoản?';

  @override
  String get login_get_started => 'Bắt đầu';

  @override
  String get login_app_name => 'Quản lý chi tiêu';

  @override
  String get login_welcome_back => 'Chào mừng trở lại';

  @override
  String get login_enter_details => 'Nhập thông tin của bạn bên dưới';

  @override
  String get login_phone_label => 'Số điện thoại';

  @override
  String get login_phone_hint => '+84 123 456 789';

  @override
  String get login_sign_in_btn => 'Đăng nhập';

  @override
  String get login_or_sign_in_with => 'Hoặc đăng nhập bằng';

  @override
  String get login_google => 'Google';

  @override
  String get login_facebook => 'Facebook';

  @override
  String get otp_title => 'Nhập mã OTP';

  @override
  String get otp_subtitle =>
      'Chúng tôi đã gửi mã xác nhận 6 số đến điện thoại của bạn.';
}
