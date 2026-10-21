import '../data/race.dart';
import '../data/race_repository.dart';
import 'collection_model.dart';

class RaceCatalog extends CollectionModel<Race> {
  RaceCatalog(RaceRepository super.repository);
}
