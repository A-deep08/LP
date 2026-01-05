import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc() : super(SignupInitial()) {
    on<SignupSubmitted>(_onSignupSubmitted);
  }

  Future<void> _onSignupSubmitted(
    SignupSubmitted event,
    Emitter<SignupState> emit,
  ) async {
    emit(SignupLoading());

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password.trim(),
      );

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
            'username': event.username.trim(),
            'email': event.email.trim(),
          });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', event.username.trim());

      emit(SignupSuccess());
    } on FirebaseAuthException catch (e) {
      String msg = 'Signup failed';

      if (e.code == 'email-already-in-use') {
        msg = 'Email already exists.';
      } else if (e.code == 'invalid-email') {
        msg = 'Invalid email format.';
      } else if (e.code == 'weak-password') {
        msg = 'Password is too weak.';
      }

      emit(SignupFailure(msg));
    } catch (e) {
      
      emit(SignupFailure(e.toString()));
    }
  }
}
