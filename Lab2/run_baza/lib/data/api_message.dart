import 'dart:convert';

import 'package:http/http.dart' as http;

/// Server messages are diagnostic text, not translated UI copy.
String apiMessage(http.Response response, {bool signingIn = false}) {
  try {
    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final error = body['error'] as Map<String, dynamic>;
    final code = error['code'] as String;
    return switch (code) {
      'VALIDATION_ERROR' => 'Проверьте заполненные поля.',
      'UNAUTHORIZED' =>
        signingIn
            ? 'Неверный email или пароль.'
            : 'Сессия завершена. Войдите снова.',
      'EMAIL_TAKEN' => 'Аккаунт с этим email уже существует.',
      'CONFLICT' => 'Запись уже существует или связана с другими данными.',
      'NOT_FOUND' => 'Запись не существует.',
      _ => 'Ошибка сервера (${response.statusCode}). Попробуйте позже.',
    };
  } on FormatException {
    return 'Ошибка сервера (${response.statusCode}).';
  } on TypeError {
    return 'Ошибка сервера (${response.statusCode}).';
  }
}
