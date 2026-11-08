import 'package:flutter/services.dart';

import 'api_client.dart';
import 'result.dart';
import 'token_store.dart';

class AuthApi {
  AuthApi(this.api);
  final ApiClient api;

  Future<Result<void>> login(String email, String password) => _post(
    '/auth/login',
    {'email': email.trim().toLowerCase(), 'password': password},
    200,
  );

  Future<Result<void>> register(String email, String password, String name) =>
      _post('/auth/register', {
        'email': email.trim().toLowerCase(),
        'password': password,
        'name': name.trim(),
      }, 201);

  Future<Result<void>> _post(
    String path,
    Map<String, Object?> body,
    int status,
  ) async {
    final result = await api.request<String>(
      'POST',
      path,
      successStatus: status,
      authenticated: false,
      signingIn: true,
      body: body,
      decode: (json) {
        final token = (json as Map<String, dynamic>)['token'] as String;
        if (token.trim().isEmpty) throw const FormatException('Empty token');
        return token;
      },
    );
    switch (result) {
      case Err(:final msg):
        return Err(msg);
      case Ok(:final value):
        try {
          await api.tokens.save(value);
          return const Ok(null);
        } on TokenStorageException {
          return const Err('Не удалось сохранить сессию. Повторите вход.');
        } on PlatformException {
          return const Err('Хранилище сессии недоступно. Повторите вход.');
        }
    }
  }

  Future<Result<void>> logout() async {
    try {
      await api.tokens.clear();
      return const Ok(null);
    } on TokenStorageException {
      return const Err('Не удалось завершить сессию. Повторите попытку.');
    } on PlatformException {
      return const Err('Хранилище сессии недоступно. Повторите попытку.');
    }
  }
}
