import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:run_baza/data/api_client.dart';
import 'package:run_baza/data/http_repositories.dart';
import 'package:run_baza/data/race.dart';
import 'package:run_baza/data/plan_entry.dart';
import 'package:run_baza/data/runner_profile.dart';
import 'package:run_baza/data/transfer.dart';
import 'package:run_baza/data/result.dart';

import 'support/fixtures.dart' as fixture;
import 'support/test_app.dart';

void main() {
  test('entity JSON round trips preserve every editable field', () {
    for (final race in fixture.races) {
      expect(
        Race.fromJson({'id': race.id, ...race.toJson()}).toJson(),
        race.toJson(),
      );
    }
    final p = fixture.plan.first;
    expect(
      PlanEntry.fromJson({'id': p.id, ...p.toJson()}).toJson(),
      p.toJson(),
    );
    final o = fixture.offers.first;
    expect(
      TransferOffer.fromJson({'id': o.id, ...o.toJson()}).toJson(),
      o.toJson(),
    );
    final r = fixture.requests.first;
    expect(
      SeatRequest.fromJson({'id': r.id, ...r.toJson()}).toJson(),
      r.toJson(),
    );
    final u = fixture.runnerProfile;
    expect(
      RunnerProfile.fromJson({'id': u.id, ...u.toJson()}).toJson(),
      u.toJson(),
    );
    expect(u.toJson().containsKey('id'), isFalse);
  });
  test('HTTP repository encodes query and takes IDs from response', () async {
    final token = MemoryTokens()..value = 'session';
    final client = ApiClient(
      'http://localhost:8080',
      token,
      client: MockClient((req) async {
        expect(req.headers['Authorization'], 'Bearer session');
        if (req.method == 'GET') {
          expect(req.url.queryParameters, {
            'page': '2',
            'limit': '20',
            'search': 'Кишинёв',
            'country': 'moldova',
          });
          return http.Response(
            jsonEncode({
              'items': [
                {'id': 'server-1', ...fixture.races.first.toJson()},
              ],
              'page': 2,
              'limit': 20,
              'total': 21,
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        if (req.method == 'DELETE') return http.Response('', 204);
        final body = jsonDecode(req.body) as Map;
        expect(body.containsKey('id'), isFalse);
        return http.Response(
          jsonEncode({'id': 'server-2', ...body}),
          req.method == 'POST' ? 201 : 200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );
    final repo = HttpRaceRepository(client);
    expect(
      ((await repo.fetchAll(
        page: 2,
        search: 'Кишинёв',
        country: 'moldova',
      )) as Ok<List<Race>>).value.single.id,
      'server-1',
    );
    expect(
      ((await repo.create(fixture.races.first)) as Ok<Race>).value.id,
      'server-2',
    );
    expect(await repo.delete('server-2'), isA<Ok<void>>());
    client.close();
  });
}
