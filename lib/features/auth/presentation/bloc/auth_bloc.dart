import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:expense_management/core/constants/app_constants.dart';
import 'package:expense_management/core/utils/auth_token_manager.dart';
import 'package:expense_management/core/network/error_handler.dart';
import 'package:expense_management/features/auth/domain/usecases/login_usecase.dart';
import 'package:expense_management/features/auth/domain/usecases/register_usecase.dart';
import 'package:expense_management/features/auth/domain/usecases/google_login_usecase.dart';
import 'package:expense_management/features/auth/domain/usecases/logout_usecase.dart';
import 'package:expense_management/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:expense_management/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:expense_management/features/auth/data/repositories/auth_repository_impl.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth;
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final GoogleLoginUseCase _googleLoginUseCase;
  final LogoutUseCase _logoutUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  AuthBloc({
    FirebaseAuth? auth,
    LoginUseCase? loginUseCase,
    RegisterUseCase? registerUseCase,
    GoogleLoginUseCase? googleLoginUseCase,
    LogoutUseCase? logoutUseCase,
    ForgotPasswordUseCase? forgotPasswordUseCase,
    ResetPasswordUseCase? resetPasswordUseCase,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _loginUseCase = loginUseCase ?? LoginUseCase(AuthRepositoryImpl()),
        _registerUseCase = registerUseCase ?? RegisterUseCase(AuthRepositoryImpl()),
        _googleLoginUseCase = googleLoginUseCase ?? GoogleLoginUseCase(AuthRepositoryImpl()),
        _logoutUseCase = logoutUseCase ?? LogoutUseCase(AuthRepositoryImpl()),
        _forgotPasswordUseCase = forgotPasswordUseCase ?? ForgotPasswordUseCase(AuthRepositoryImpl()),
        _resetPasswordUseCase = resetPasswordUseCase ?? ResetPasswordUseCase(AuthRepositoryImpl()),
        super(AuthTokenManager.isLoggedIn() ? AuthSuccess() : AuthInitial()) {
    on<LoginWithEmailEvent>(_onLoginWithEmail);
    on<RegisterWithEmailEvent>(_onRegisterWithEmail);
    on<LoginWithGoogleEvent>(_onLoginWithGoogle);
    on<LoginWithPhoneEvent>(_onLoginWithPhone);
    on<PhoneAuthCodeSentEvent>(_onPhoneAuthCodeSent);
    on<PhoneAuthVerificationFailedEvent>(_onPhoneAuthVerificationFailed);
    on<PhoneAuthVerificationCompletedEvent>(_onPhoneAuthVerificationCompleted);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ResetPasswordEvent>(_onResetPassword);
    on<LogoutEvent>(_onLogout);
    on<BypassLoginDevEvent>(_onBypassLoginDev);
  }

  Future<void> _onLoginWithEmail(LoginWithEmailEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _loginUseCase(event.email, event.password);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure(ErrorHandler.handle(e).failure.message));
    }
  }

  Future<void> _onRegisterWithEmail(RegisterWithEmailEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _registerUseCase(event.email, event.password, event.displayName);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure(ErrorHandler.handle(e).failure.message));
    }
  }

  Future<void> _onLoginWithGoogle(LoginWithGoogleEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: AppConstants.googleWebClientId.isNotEmpty
            ? AppConstants.googleWebClientId
            : null,
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

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

      // Verify token via backend through use case
      await _googleLoginUseCase(idToken);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure(ErrorHandler.handle(e).failure.message));
    }
  }

  Future<void> _onLoginWithPhone(LoginWithPhoneEvent event, Emitter<AuthState> emit) async {
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
          // Can be handled if needed
        },
      );
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  void _onPhoneAuthCodeSent(PhoneAuthCodeSentEvent event, Emitter<AuthState> emit) {
    emit(AuthOtpSent(event.verificationId));
  }

  void _onPhoneAuthVerificationFailed(PhoneAuthVerificationFailedEvent event, Emitter<AuthState> emit) {
    emit(AuthFailure(event.error));
  }

  Future<void> _onPhoneAuthVerificationCompleted(PhoneAuthVerificationCompletedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _auth.signInWithCredential(event.credential);
      emit(AuthSuccess());
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message ?? 'Sign in failed.'));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
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
  }

  Future<void> _onForgotPassword(ForgotPasswordEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _forgotPasswordUseCase(event.email);
      emit(ForgotPasswordSuccess(result.token));
    } catch (e) {
      emit(AuthFailure(ErrorHandler.handle(e).failure.message));
    }
  }

  Future<void> _onResetPassword(ResetPasswordEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final message = await _resetPasswordUseCase(event.email, event.token, event.newPassword);
      emit(ResetPasswordSuccess(message));
    } catch (e) {
      emit(AuthFailure(ErrorHandler.handle(e).failure.message));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final refreshToken = AuthTokenManager.getRefreshToken();
      await _logoutUseCase(refreshToken ?? '');
      await Future.wait([
        _auth.signOut(),
        GoogleSignIn(
          serverClientId: AppConstants.googleWebClientId.isNotEmpty
              ? AppConstants.googleWebClientId
              : null,
        ).signOut(),
      ]);
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onBypassLoginDev(BypassLoginDevEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Save dummy credentials so AuthTokenManager.isLoggedIn() returns true
      await AuthTokenManager.saveAuthData(
        token: 'dummy_dev_token',
        refreshToken: 'dummy_dev_refresh_token',
        userId: 'dev_user_id',
        email: 'dev@example.com',
        name: 'Developer',
      );
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
