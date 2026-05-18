import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {
    on<LoginWithEmailEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(AuthSuccess());
      } on FirebaseAuthException catch (e) {
        emit(AuthFailure(e.message ?? 'Unknown error occurred.'));
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
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth.signInWithCredential(credential);
        emit(AuthSuccess());
      } on FirebaseAuthException catch (e) {
        emit(AuthFailure(e.message ?? 'Đăng nhập Google thất bại.'));
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
  }
}
