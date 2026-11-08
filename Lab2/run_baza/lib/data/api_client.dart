import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'api_message.dart';
import 'result.dart';
import 'token_store.dart';

/// HTTP transport shared by repositories and authentication.
/// Navigation belongs to the composition root via onUnauthorized.
class ApiClient {
  ApiClient(
    this.baseUrl,
    this.tokens, {
    http.Client? client,
    this.timeout = const Duration(seconds: 8),
    this.onUnauthorized,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final TokenStore tokens;
  final Duration timeout;
  final void Function()? onUnauthorized;
  final http.Client _client;
  Future<void>? _invalidating;

  Future<void> _expire(String? sentToken) async {
    if (_invalidating != null) return _invalidating;
    final task = _clearExpired(sentToken);
    _invalidating = task;
    try {
      await task;
    } finally {
      _invalidating = null;
    }
  }

  Future<void> _clearExpired(String? sentToken) async {
    // An old request must not remove a token from a newer login.
    if (await tokens.read() != sentToken) return;
    await tokens.clear();
    onUnauthorized?.call();
  }

  Future<Result<T>> request<T>(
    String method,
    String path, {
    required int successStatus,
    required T Function(Object? json) decode,
    Map<String, String>? query,
    Map<String, Object?>? body,
    bool authenticated = true,
    bool signingIn = false,
  }) async {
    try {
      final token = authenticated ? await tokens.read() : null;
      final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
      final request = http.Request(method, uri)
        ..headers['Accept'] = 'application/json';
      if (authenticated && token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      if (body != null) {
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode(body);
      }
      // The deadline includes receiving the response body, not only headers.
      final response = await (() async {
        final stream = await _client.send(request);
        return http.Response.fromStream(stream);
      })().timeout(timeout);
      if (response.statusCode == 401 && authenticated) {
        await _expire(token);
        return const Err('Сессия завершена. Войдите снова.');
      }
      if (response.statusCode != successStatus) {
        return Err(apiMessage(response, signingIn: signingIn));
      }
      // A successful DELETE has no JSON body.
      final json = successStatus == 204
          ? null
          : jsonDecode(utf8.decode(response.bodyBytes));
      return Ok(decode(json));
    } on SocketException {
      return const Err('Не удалось подключиться к серверу. Повторите попытку.');
    } on http.ClientException {
      return const Err('Не удалось подключиться к серверу. Повторите попытку.');
    } on TimeoutException {
      return const Err('Сервер не отвечает. Повторите попытку.');
    } on FormatException {
      return const Err('Сервер вернул некорректные данные.');
    } on TypeError {
      return const Err('Сервер вернул некорректные данные.');
    } on TokenStorageException {
      return const Err('Не удалось сохранить сессию. Повторите вход.');
    } on PlatformException {
      return const Err('Хранилище сессии недоступно. Повторите вход.');
    }
  }

  void close() => _client.close();
}
