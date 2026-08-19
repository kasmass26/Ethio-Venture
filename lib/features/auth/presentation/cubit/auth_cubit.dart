import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, Supabase;

import '../../../../core/error/exceptions.dart'
    show EmailConfirmationRequiredException;
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final LogoutUser logoutUser;

  AuthCubit({
    required this.loginUser,
    required this.registerUser,
    required this.logoutUser,
  }) : super(const AuthInitial());

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());
    try {
      final user = await loginUser(email: email, password: password);
      emit(Authenticated(user));
    } catch (error, stackTrace) {
      developer.log(
        'Login failed for email=$email',
        name: 'EthioVenture.Auth',
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
      emit(AuthFailureState(_mapError(error)));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await registerUser(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      // Confirm-email sign-ups create a user without a session. Sending that
      // user to a protected dashboard makes registration look broken.
      if (Supabase.instance.client.auth.currentSession == null) {
        emit(const EmailConfirmationRequired());
      } else {
        emit(Authenticated(user));
      }
    } catch (error, stackTrace) {
      developer.log(
        'Registration failed for email=$email, role=$role',
        name: 'EthioVenture.Auth',
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
      emit(AuthFailureState(_mapError(error)));
    }
  }

  Future<void> logout() async {
    emit(const AuthLoading());
    try {
      await logoutUser();
      emit(const Unauthenticated());
    } catch (error, stackTrace) {
      developer.log(
        'Logout failed.',
        name: 'EthioVenture.Auth',
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
      emit(AuthFailureState(_mapError(error)));
    }
  }

  static String _mapError(dynamic e) {
    if (e is AuthException) {
      final msg = e.message.toLowerCase();
      final code = e.code?.toLowerCase() ?? '';

      if (e.statusCode == '429' ||
          code.contains('rate_limit') ||
          msg.contains('rate limit')) {
        return 'Email rate limit exceeded. Supabase limits sign-up emails on the default mail server (3-4/hour). Please wait a few minutes, or sign in if your account is already created.';
      }
      if (code.contains('already_exists') ||
          msg.contains('already registered') ||
          msg.contains('already exists')) {
        return 'An account with this email already exists. Please sign in instead.';
      }
      if (code.contains('invalid_credentials') ||
          msg.contains('invalid login credentials')) {
        return 'Invalid email or password. Please check your credentials.';
      }
      return e.message;
    }

    final raw = e.toString().replaceAll('Exception: ', '').trim();
    if (raw.toLowerCase().contains('rate limit')) {
      return 'Email rate limit exceeded. Please wait a few minutes before '
          'trying again.';
    }
    return raw;
  }
}
