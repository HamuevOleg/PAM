import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'auth_api.dart';
import 'result.dart';
import 'token_store.dart';

const apiBase = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8080',
);

class SessionController extends ChangeNotifier {
  SessionController({
    TokenStore? tokens,
    http.Client? client,
    String baseUrl = apiBase,
    this._signedIn = false,
  }) : tokens = tokens ?? TokenStore() {
    api = ApiClient(
      baseUrl,
      this.tokens,
      client: client,
      onUnauthorized: _expired,
    );
    auth = AuthApi(api);
  }
  final TokenStore tokens;
  late final ApiClient api;
  late final AuthApi auth;
  bool _signedIn;
  bool get signedIn => _signedIn;
  int generation = 0;

  Future<void> restore() async {
    _signedIn = await tokens.read() != null;
  }

  void _expired() {
    _signedIn = false;
    generation++;
    notifyListeners();
  }

  Future<Result<void>> login(String email, String password) async =>
      _accept(await auth.login(email, password));
  Future<Result<void>> register(
    String email,
    String password,
    String name,
  ) async => _accept(await auth.register(email, password, name));
  void acceptLogin() => _accept(const Ok<void>(null));
  Result<void> _accept(Result<void> result) {
    if (result is Ok<void>) {
      _signedIn = true;
      generation++;
      notifyListeners();
    }
    return result;
  }

  Future<Result<void>> logout() async {
    final result = await auth.logout();
    if (result is Ok<void>) _expired();
    return result;
  }

  @override
  void dispose() {
    api.close();
    super.dispose();
  }
}
