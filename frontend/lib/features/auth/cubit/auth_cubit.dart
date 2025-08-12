import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/services/shared_prefs_services.dart';
import 'package:frontend/features/auth/repositories/auth_remote_repository.dart';
import 'package:frontend/models/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final authRemoteRepository = AuthRemoteRepository();
  final sharedPrefsServices = SharedPrefsServices();

  void getUserData() async {
    try {
      emit(AuthLoading());
      await authRemoteRepository.getUserData();
      final userModel = await authRemoteRepository.getUserData();
      if (userModel != null) {
        emit(AuthLoggedIn(userModel));
        return;
      }
      emit(AuthInitial());
    } catch (e) {
      emit(AuthInitial());
    }
  }

  void signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      await authRemoteRepository.signUp(
        name: name,
        email: email,
        password: password,
      );

      emit(AuthSignUp());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void login({required String email, required String password}) async {
    try {
      emit(AuthLoading());
      final userModel = await authRemoteRepository.login(
        email: email,
        password: password,
      );

      if (userModel.token.isNotEmpty) {
        await sharedPrefsServices.setToken(userModel.token);
      }
      emit(AuthLoggedIn(userModel));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
