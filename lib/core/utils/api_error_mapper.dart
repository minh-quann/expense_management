import 'package:dio/dio.dart';

/// Helper class to map API error codes and network exceptions to friendly Vietnamese messages
class ApiErrorMapper {
  ApiErrorMapper._();

  /// Map of error codes to Vietnamese error messages
  static const Map<String, String> _errorMap = {
    // Auth Error Codes
    'AUTH_EMAIL_ALREADY_REGISTERED': 'Email này đã được đăng ký trước đó.',
    'AUTH_PASSWORD_PROCESSING_FAILED': 'Xử lý mật khẩu thất bại. Vui lòng thử lại.',
    'AUTH_USER_UPDATE_FAILED': 'Cập nhật thông tin người dùng thất bại.',
    'AUTH_TRANSACTION_FAILED': 'Giao dịch trên hệ thống gặp lỗi. Vui lòng thử lại.',
    'AUTH_TOKEN_GENERATION_FAILED': 'Tạo mã truy cập thất bại.',
    'AUTH_REFRESH_TOKEN_GENERATION_FAILED': 'Tạo mã làm mới phiên thất bại.',
    'AUTH_DATABASE_ERROR': 'Lỗi kết nối cơ sở dữ liệu.',
    'AUTH_PASSWORD_HASH_FAILED': 'Không thể mã hóa bảo mật mật khẩu.',
    'AUTH_USER_CREATION_FAILED': 'Đăng ký tài khoản mới thất bại.',
    'AUTH_SEED_DATA_FAILED': 'Thiết lập dữ liệu ban đầu thất bại.',
    'AUTH_INVALID_CREDENTIALS': 'Email hoặc mật khẩu không chính xác.',
    'AUTH_GOOGLE_ONLY_ACCOUNT': 'Tài khoản này chỉ đăng ký qua Google. Vui lòng chọn Đăng nhập bằng Google.',
    'AUTH_GOOGLE_TOKEN_INVALID': 'Mã đăng nhập Google không hợp lệ.',
    'AUTH_GOOGLE_LINK_FAILED': 'Không thể liên kết tài khoản Google này.',
    'AUTH_INVALID_REFRESH_TOKEN': 'Mã phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại.',
    'AUTH_REFRESH_TOKEN_EXPIRED': 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
    'AUTH_EMAIL_NOT_FOUND': 'Không tìm thấy tài khoản nào khớp với email này.',
    'AUTH_GOOGLE_ONLY_RESET_UNAVAILABLE': 'Tài khoản đăng ký qua Google nên không cần đặt lại mật khẩu.',
    'AUTH_RESET_CODE_GENERATION_FAILED': 'Tạo mã xác thực đặt lại mật khẩu thất bại.',
    'AUTH_RESET_CODE_SAVE_FAILED': 'Lưu mã đặt lại mật khẩu thất bại.',
    'AUTH_RESET_EMAIL_SEND_FAILED': 'Không thể gửi email chứa mã khôi phục mật khẩu. Vui lòng kiểm tra lại cấu hình.',
    'AUTH_INVALID_RESET_CODE': 'Mã khôi phục hoặc email không chính xác.',
    'AUTH_RESET_CODE_EXPIRED': 'Mã khôi phục mật khẩu đã hết hạn.',
    'AUTH_USER_NOT_FOUND': 'Không tìm thấy người dùng trên hệ thống.',
    'AUTH_PASSWORD_UPDATE_FAILED': 'Không thể thay đổi mật khẩu mới.',
    'AUTH_INVALID_REQUEST': 'Yêu cầu không hợp lệ hoặc dữ liệu sai định dạng.',
    'GENERIC_ERROR': 'Đã xảy ra lỗi hệ thống.',
  };

  /// Extract and map message from DioException or generic error
  static String getErrorMessage(Object error) {
    if (error is DioException) {
      // Check network-level exceptions
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.';
        case DioExceptionType.sendTimeout:
          return 'Gửi yêu cầu quá thời gian cho phép. Vui lòng thử lại.';
        case DioExceptionType.receiveTimeout:
          return 'Phản hồi từ máy chủ quá thời gian cho phép. Vui lòng thử lại.';
        case DioExceptionType.badResponse:
          final responseData = error.response?.data;
          if (responseData is Map && responseData.containsKey('error')) {
            final errObj = responseData['error'];
            if (errObj is Map) {
              final code = errObj['code']?.toString();
              final message = errObj['message']?.toString();
              
              if (code != null && _errorMap.containsKey(code)) {
                return _errorMap[code]!;
              }
              if (message != null && message.isNotEmpty) {
                return message;
              }
            } else if (errObj is String) {
              // Backward compatibility if error is just a string
              return errObj;
            }
          }
          return 'Máy chủ phản hồi lỗi không xác định (${error.response?.statusCode}).';
        case DioExceptionType.cancel:
          return 'Yêu cầu đã bị hủy.';
        case DioExceptionType.connectionError:
          return 'Không có kết nối Internet hoặc không thể kết nối tới máy chủ.';
        default:
          return 'Đã xảy ra lỗi kết nối mạng. Vui lòng kiểm tra lại.';
      }
    }

    return error.toString();
  }
}
