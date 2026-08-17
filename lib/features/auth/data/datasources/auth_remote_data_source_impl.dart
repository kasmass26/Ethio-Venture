import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client _client;

  AuthRemoteDataSourceImpl({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String role,
  }) async {
    final normalizedEmail = email.trim();
    if (!normalizedEmail.contains('@')) {
      throw const FormatException('Please enter a valid email address.');
    }

    if (password.length < 6) {
      throw const FormatException(
        'Password must be at least 6 characters long.',
      );
    }

    final roleValue = role == UserRole.investor.name
        ? UserRole.investor
        : UserRole.startup;

    return UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: normalizedEmail.split('@').first,
      email: normalizedEmail,
      role: roleValue,
    );
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();
    if (!normalizedEmail.contains('@')) {
      throw const FormatException('Please enter a valid email address.');
    }

    if (password.length < 6) {
      throw const FormatException(
        'Password must be at least 6 characters long.',
      );
    }

    final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.login}');

    try {
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': normalizedEmail,
          'password': password,
        }),
      );

      final decodedBody = response.body.trim().isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw ServerException(
          message: 'Invalid email or password',
          statusCode: response.statusCode,
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic payload = decodedBody is Map && decodedBody.containsKey('user')
            ? decodedBody['user']
            : decodedBody is Map && decodedBody.containsKey('data')
                ? decodedBody['data']
                : decodedBody;

        if (payload is! Map<String, dynamic> && payload is! Map) {
          throw ServerException(
            message: 'Invalid response from server.',
            statusCode: response.statusCode,
          );
        }

        final userJson = Map<String, dynamic>.from(payload as Map);
        return UserModel.fromJson(userJson);
      }

      final message = _extractServerErrorMessage(decodedBody);
      throw ServerException(
        message: message,
        statusCode: response.statusCode,
      );
    } on ServerException {
      rethrow;
    } on FormatException {
      rethrow;
    } on http.ClientException catch (e, stackTrace) {
      debugPrint('Login request failed with client exception: $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ServerException(
        message: 'Network error. Please check your connection and try again.',
      );
    } catch (e, stackTrace) {
      debugPrint('Unexpected login exception: $e');
      debugPrintStack(stackTrace: stackTrace);
      throw ServerException(
        message: 'Something went wrong. Please try again later.',
      );
    }
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}

String _extractServerErrorMessage(dynamic decodedBody) {
  if (decodedBody is Map<String, dynamic>) {
    final message = decodedBody['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
  }

  if (decodedBody is Map) {
    final message = decodedBody['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
  }

  return 'Authentication failed. Please try again.';
}
