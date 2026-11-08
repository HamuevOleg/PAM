import 'api_client.dart';
import 'http_repositories.dart';
import 'race_repository.dart';
import 'plan_repository.dart';
import 'offer_repository.dart';
import 'request_repository.dart';
import 'profile_repository.dart';

class Repositories {
  const Repositories({
    required this.races,
    required this.plan,
    required this.offers,
    required this.requests,
    required this.profile,
  });
  factory Repositories.http(ApiClient api) => Repositories(
    races: HttpRaceRepository(api),
    plan: HttpPlanRepository(api),
    offers: HttpOfferRepository(api),
    requests: HttpRequestRepository(api),
    profile: HttpProfileRepository(api),
  );
  final RaceRepository races;
  final PlanRepository plan;
  final OfferRepository offers;
  final RequestRepository requests;
  final ProfileRepository profile;
}
