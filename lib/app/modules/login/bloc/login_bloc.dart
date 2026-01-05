import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_mate/app/modules/login/bloc/login_event.dart';
import 'package:study_mate/app/modules/login/bloc/login_state.dart';


class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>(onLoginSubmitted);
  }

  Future<void> onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      await auth.signInWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password.trim(),
      );
      emit(LoginSuccess());
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        message = 'Email format is invalid.';
      }
      emit(LoginFailure(message));
    } catch (_) {
      emit(LoginFailure('Something went wrong.'));
    }
  }
}
