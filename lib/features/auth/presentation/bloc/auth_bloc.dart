import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:expense_management/core/network/api_client.dart';
import 'package:expense_management/core/utils/auth_token_manager.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(AuthTokenManager.isLoggedIn() ? AuthSuccess() : AuthInitial()) {
    on<LoginWithEmailEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await ApiClient().dio.post('/auth/login', data: {
          'email': event.email,
          'password': event.password,
        });

        final token = response.data['token'];
        final refreshToken = response.data['refresh_token'] ?? '';
        final userData = response.data['user'];

        await AuthTokenManager.saveAuthData(
          token: token,
          refreshToken: refreshToken,
          userId: userData['id'],
          email: userData['email'],
          name: userData['display_name'] ?? '',
        );

        emit(AuthSuccess());
      } on DioException catch (e) {
        final errorMessage = e.response?.data['error'] ?? 'Login failed';
        emit(AuthFailure(errorMessage.toString()));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<RegisterWithEmailEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await ApiClient().dio.post('/auth/register', data: {
          'email': event.email,
          'password': event.password,
          'display_name': event.displayName,
        });

        final token = response.data['token'];
        final refreshToken = response.data['refresh_token'] ?? '';
        final userData = response.data['user'];

        await AuthTokenManager.saveAuthData(
          token: token,
          refreshToken: refreshToken,
          userId: userData['id'],
          email: userData['email'],
          name: userData['display_name'] ?? '',
        );

        emit(AuthSuccess());
      } on DioException catch (e) {
        final errorMessage = e.response?.data['error'] ?? 'Registration failed';
        emit(AuthFailure(errorMessage.toString()));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LoginWithGoogleEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        
        // Canceled sign in
        if (googleUser == null) {
          emit(AuthInitial());
          return;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final String? idToken = googleAuth.idToken;

        if (idToken == null) {
          emit(AuthFailure('Could not retrieve Google ID Token'));
          return;
        }

        // Verify token on the Go backend
        final response = await ApiClient().dio.post('/auth/google', data: {
          'id_token': idToken,
        });

        final token = response.data['token'];
        final refreshToken = response.data['refresh_token'] ?? '';
        final userData = response.data['user'];

        await AuthTokenManager.saveAuthData(
          token: token,
          refreshToken: refreshToken,
          userId: userData['id'],
          email: userData['email'],
          name: userData['display_name'] ?? '',
        );

        emit(AuthSuccess());
      } on DioException catch (e) {
        final errorMessage = e.response?.data['error'] ?? 'Google login on backend failed';
        emit(AuthFailure(errorMessage.toString()));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LoginWithPhoneEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await _auth.verifyPhoneNumber(
          phoneNumber: event.phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) {
            add(PhoneAuthVerificationCompletedEvent(credential));
          },
          verificationFailed: (FirebaseAuthException e) {
            add(PhoneAuthVerificationFailedEvent(e.message ?? 'Verification failed.'));
          },
          codeSent: (String verificationId, int? resendToken) {
            add(PhoneAuthCodeSentEvent(verificationId, resendToken));
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            // Can be handled if needed, usually just ignore
          },
        );
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<PhoneAuthCodeSentEvent>((event, emit) {
      emit(AuthOtpSent(event.verificationId));
    });

    on<PhoneAuthVerificationFailedEvent>((event, emit) {
      emit(AuthFailure(event.error));
    });

    on<PhoneAuthVerificationCompletedEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await _auth.signInWithCredential(event.credential);
        emit(AuthSuccess());
      } on FirebaseAuthException catch (e) {
        emit(AuthFailure(e.message ?? 'Sign in failed.'));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<VerifyOtpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: event.verificationId,
          smsCode: event.otpCode,
        );
        await _auth.signInWithCredential(credential);
        emit(AuthSuccess());
      } on FirebaseAuthException catch (e) {
        emit(AuthFailure(e.message ?? 'Invalid OTP code.'));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<ForgotPasswordEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await ApiClient().dio.post('/auth/forgot-password', data: {
          'email': event.email,
        });
        final token = response.data['token'] ?? '';
        emit(ForgotPasswordSuccess(token));
      } on DioException catch (e) {
        final errorMessage = e.response?.data['error'] ?? 'Yêu cầu đặt lại mật khẩu thất bại';
        emit(AuthFailure(errorMessage.toString()));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<ResetPasswordEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await ApiClient().dio.post('/auth/reset-password', data: {
          'email': event.email,
          'token': event.token,
          'new_password': event.newPassword,
        });
        final message = response.data['message'] ?? 'Đặt lại mật khẩu thành công';
        emit(ResetPasswordSuccess(message));
      } on DioException catch (e) {
        final errorMessage = e.response?.data['error'] ?? 'Đặt lại mật khẩu thất bại';
        emit(AuthFailure(errorMessage.toString()));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LogoutEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await AuthTokenManager.clearAuthData();
        await Future.wait([
          _auth.signOut(),
          GoogleSignIn().signOut(),
        ]);
        emit(AuthInitial());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}
