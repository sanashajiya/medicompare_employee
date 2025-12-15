import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;

  AuthBloc({required this.loginUseCase}) : super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    print('🔐 Login attempt for: ${event.email}');
    emit(AuthLoading());

    try {
      final user = await loginUseCase(
        email: event.email,
        password: event.password,
      );
      print('✅ Login successful! User: ${user.name}, Email: ${user.email}');
      emit(AuthSuccess(user));
      print('✅ AuthSuccess state emitted');
    } on Exception catch (e) {
      // Extract error message from Exception
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      print('❌ Login failed with exception: $errorMessage');
      emit(AuthFailure(errorMessage));
    } catch (e) {
      print('❌ Login failed with error: $e');
      emit(AuthFailure('An unexpected error occurred. Please try again.'));
    }
  }
}
