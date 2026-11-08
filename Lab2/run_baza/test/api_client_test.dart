import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:run_baza/data/api_client.dart';
import 'package:run_baza/data/auth_api.dart';
import 'package:run_baza/data/result.dart';
import 'package:run_baza/data/token_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TokenStore tokens;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    tokens = TokenStore();
  });

  ApiClient api(
    Future<http.Response> Function(http.Request) respond, {
    void Function()? expired,
    Duration? timeout,
  }) => ApiClient(
    'http://localhost:8080',
    tokens,
    client: MockClient(respond),
    onUnauthorized: expired,
    timeout: timeout ?? const Duration(seconds: 1),
  );

  Future<Result<String>> get(ApiClient client) => client.request(
    'GET',
    '/notes',
    successStatus: 200,
    decode: (json) => (json as Map<String, dynamic>)['title'] as String,
  );

  test('login stores only a token and normalizes email', () async {
    final client = api((request) async {
      expect(request.url.path, '/auth/login');
      expect(request.headers.containsKey('Authorization'), isFalse);
      expect(jsonDecode(request.body), {
        'email': 'runner@example.com',
        'password': 'secret123',
      });
      return http.Response('{"token":"signed-token"}', 200);
    });
    expect(
      await AuthApi(client).login(' Runner@Example.com ', 'secret123'),
      isA<Ok<void>>(),
    );
    expect(await TokenStore().read(), 'signed-token');
    expect((await SharedPreferences.getInstance()).getKeys(), {TokenStore.key});
    expect(await AuthApi(client).logout(), isA<Ok<void>>());
    expect(await tokens.read(), isNull);
    client.close();
  });

  test('registration sends name and accepts 201', () async {
    final client = api((request) async {
      expect(request.url.path, '/auth/register');
      expect(jsonDecode(request.body)['name'], 'Oleg');
      return http.Response('{"token":"registration-token"}', 201);
    });
    expect(
      await AuthApi(client).register('o@example.com', 'secret123', ' Oleg '),
      isA<Ok<void>>(),
    );
    expect(await tokens.read(), 'registration-token');
    client.close();
  });

  test('401 clears token before notifying the composition root', () async {
    await tokens.save('expired-token');
    var calls = 0;
    final client = api(
      (request) async {
        expect(request.headers['Authorization'], 'Bearer expired-token');
        return http.Response('{"error":{"code":"UNAUTHORIZED"}}', 401);
      },
      expired: () {
        calls++;
      },
    );
    expect(await get(client), isA<Err<String>>());
    expect(await tokens.read(), isNull);
    expect(calls, 1);
    client.close();
  });

  test('a delayed 401 cannot erase a newer session', () async {
    await tokens.save('old-token');
    var calls = 0;
    final client = api((_) async {
      await tokens.save('new-token');
      return http.Response('', 401);
    }, expired: () => calls++);
    await get(client);
    expect(await tokens.read(), 'new-token');
    expect(calls, 0);
    client.close();
  });

  test(
    'invalid credentials stay on auth without firing session expiry',
    () async {
      var calls = 0;
      final client = api(
        (_) async => http.Response(
          '{"error":{"code":"UNAUTHORIZED","message":"Invalid password"}}',
          401,
        ),
        expired: () => calls++,
      );
      final result = await AuthApi(client).login('o@example.com', 'wrong');
      expect((result as Err<void>).msg, 'Неверный email или пароль.');
      expect(calls, 0);
      expect(await tokens.read(), isNull);
      client.close();
    },
  );

  for (final code in ['EMAIL_TAKEN', 'VALIDATION_ERROR', 'NOT_FOUND']) {
    test('translates $code without displaying server prose', () async {
      final client = api(
        (_) async => http.Response(
          jsonEncode({
            'error': {'code': code, 'message': 'Raw English detail'},
          }),
          409,
        ),
      );
      final result = await get(client) as Err<String>;
      expect(result.msg, isNot(contains('Raw English')));
      client.close();
    });
  }

  for (final error in [
    const SocketException('offline'),
    http.ClientException('offline'),
    TimeoutException('late'),
  ]) {
    test('transport ${error.runtimeType} becomes a readable error', () async {
      final client = api((_) async => throw error);
      expect(await get(client), isA<Err<String>>());
      client.close();
    });
  }

  for (final body in ['<html>bad gateway</html>', '{"title":42}', '[]']) {
    test('invalid success body $body becomes a protocol error', () async {
      final client = api((_) async => http.Response(body, 200));
      expect(
        (await get(client) as Err<String>).msg,
        'Сервер вернул некорректные данные.',
      );
      client.close();
    });
  }

  test('500 with HTML has a safe fallback', () async {
    final client = api((_) async => http.Response('<html>Error</html>', 500));
    expect((await get(client) as Err<String>).msg, 'Ошибка сервера (500).');
    client.close();
  });

  test('204 delete never attempts JSON parsing', () async {
    final client = api((_) async => http.Response('', 204));
    expect(
      await client.request<void>(
        'DELETE',
        '/notes/1',
        successStatus: 204,
        decode: (_) {},
      ),
      isA<Ok<void>>(),
    );
    client.close();
  });

  test('timeout includes a stalled response body', () async {
    final stream = StreamController<List<int>>();
    final client = ApiClient(
      'http://localhost:8080',
      tokens,
      timeout: const Duration(milliseconds: 20),
      client: MockClient.streaming(
        (_, _) async => http.StreamedResponse(stream.stream, 200),
      ),
    );
    expect(
      (await get(client) as Err<String>).msg,
      'Сервер не отвечает. Повторите попытку.',
    );
    await stream.close();
    client.close();
  });

  test('empty token never authenticates', () async {
    final client = api((_) async => http.Response('{"token":""}', 200));
    expect(
      await AuthApi(client).login('o@example.com', 'secret123'),
      isA<Err<void>>(),
    );
    expect(await tokens.read(), isNull);
    client.close();
  });
}
