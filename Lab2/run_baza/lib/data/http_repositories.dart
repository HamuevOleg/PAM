import 'api_client.dart';
import 'http_repository.dart';
import 'race.dart';
import 'race_repository.dart';
import 'plan_entry.dart';
import 'plan_repository.dart';
import 'transfer.dart';
import 'offer_repository.dart';
import 'request_repository.dart';
import 'runner_profile.dart';
import 'profile_repository.dart';

class HttpRaceRepository extends HttpRepository<Race>
    implements RaceRepository {
  HttpRaceRepository(ApiClient api)
    : super(api, '/races', Race.fromJson, (value) => value.toJson());
}

class HttpPlanRepository extends HttpRepository<PlanEntry>
    implements PlanRepository {
  HttpPlanRepository(ApiClient api)
    : super(api, '/plans', PlanEntry.fromJson, (value) => value.toJson());
}

class HttpOfferRepository extends HttpRepository<TransferOffer>
    implements OfferRepository {
  HttpOfferRepository(ApiClient api)
    : super(api, '/offers', TransferOffer.fromJson, (value) => value.toJson());
}

class HttpRequestRepository extends HttpRepository<SeatRequest>
    implements RequestRepository {
  HttpRequestRepository(ApiClient api)
    : super(api, '/requests', SeatRequest.fromJson, (value) => value.toJson());
}

class HttpProfileRepository extends HttpRepository<RunnerProfile>
    implements ProfileRepository {
  HttpProfileRepository(ApiClient api)
    : super(
        api,
        '/profiles',
        RunnerProfile.fromJson,
        (value) => value.toJson(),
      );
}
