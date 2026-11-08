import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:run_baza/main.dart';
import 'package:run_baza/data/repositories.dart';
import 'package:run_baza/data/session_controller.dart';
import 'package:run_baza/data/token_store.dart';

import 'fake_repositories.dart';
import 'fixtures.dart';

class MemoryTokens extends TokenStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> save(String token) async {
    value = token;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}

class TestSources {
  TestSources() {
    repositories = Repositories(
      races: races,
      plan: MockPlanRepository(failure),
      offers: MockOfferRepository(failure),
      requests: MockRequestRepository(failure),
      profile: profile,
    );
    session = SessionController(
      tokens: MemoryTokens(),
      signedIn: true,
      client: MockClient((request) async {
        final data = jsonDecode(request.body) as Map<String, dynamic>;
        await profile.update(
          runnerProfile.copyWith(
            name: data['name'] as String? ?? runnerProfile.name,
            email: data['email'] as String,
          ),
        );
        return http.Response(
          '{"token":"test-session"}',
          request.url.path.endsWith('register') ? 201 : 200,
        );
      }),
    );
  }
  final failure = MockFailure();
  late final races = MockRaceRepository(failure);
  late final profile = MockProfileRepository(failure, latency: Duration.zero);
  late final Repositories repositories;
  late final SessionController session;
}

class TestApp extends StatefulWidget {
  const TestApp({super.key, this.router});
  final GoRouter? router;
  @override
  State<TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  final sources = TestSources();
  @override
  void dispose() {
    sources.session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Provider<MockRaceRepository>.value(
    value: sources.races,
    child: RunBazaApp(
      router: widget.router,
      session: sources.session,
      repositories: sources.repositories,
    ),
  );
}

class TestScope extends StatefulWidget {
  const TestScope({super.key, required this.child});
  final Widget child;
  @override
  State<TestScope> createState() => _TestScopeState();
}

class _TestScopeState extends State<TestScope> {
  final sources = TestSources();
  @override
  void dispose() {
    sources.session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
    value: sources.session,
    child: RunBazaScope(
      repositories: sources.repositories,
      child: widget.child,
    ),
  );
}
