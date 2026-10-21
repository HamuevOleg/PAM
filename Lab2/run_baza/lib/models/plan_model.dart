import '../data/plan_entry.dart';
import '../data/plan_repository.dart';
import 'collection_model.dart';

class PlanModel extends CollectionModel<PlanEntry> {
  PlanModel(PlanRepository repository) : super(repository);

  PlanEntry? forRace(String raceId) {
    for (final entry in records) {
      if (entry.raceId == raceId) return entry;
    }
    return null;
  }

  Future<String?> saveForRace(PlanEntry draft) {
    final existing = forRace(draft.raceId);
    return existing == null
        ? add(draft)
        : update(draft.copyWith(id: existing.id));
  }
}
