import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, Supabase;

import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/storage_service.dart';
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
      try {
        final storage = await StorageService.init();
        await storage.setOnboardingCompleted();
      } catch (_) {}
      emit(Authenticated(user));
      // Register FCM token and start Realtime notification subscription now
      // that the user is authenticated.
      final client = Supabase.instance.client;
      NotificationService.instance.onUserLoggedIn(client);
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
      try {
        final storage = await StorageService.init();
        await storage.setOnboardingCompleted();
      } catch (_) {}
      // Confirm-email sign-ups create a user without a session. Sending that
      // user to a protected dashboard makes registration look broken.
      final client = Supabase.instance.client;
      if (client.auth.currentSession == null) {
        emit(const EmailConfirmationRequired());
      } else {
        emit(Authenticated(user));
        // Register FCM token and start Realtime notification subscription.
        NotificationService.instance.onUserLoggedIn(client);
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
      // Tear down the notification channel before signing out.
      final client = Supabase.instance.client;
      await NotificationService.instance.onUserLoggedOut(client);
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
