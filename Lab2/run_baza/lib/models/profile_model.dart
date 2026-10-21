import '../data/profile_repository.dart';
import '../data/runner_identity.dart';
import '../data/runner_profile.dart';
import 'collection_model.dart';

class ProfileModel extends CollectionModel<RunnerProfile> {
  ProfileModel(ProfileRepository repository) : super(repository);
  RunnerIdentity? _identity;

  RunnerProfile? get profile {
    if (records.isEmpty) return null;
    final stored = records.first;
    return _identity == null
        ? stored
        : stored.copyWith(name: _identity!.name, email: _identity!.email);
  }

  /// Login remains local validation. This is session identity, not authentication.
  void startSession(RunnerIdentity identity) {
    _identity = identity;
    notifyListeners();
  }

  void endSession() {
    _identity = null;
    notifyListeners();
  }

  Future<String?> save(RunnerProfile draft) async {
    final message = await update(draft);
    if (message == null) {
      _identity = RunnerIdentity(name: draft.name, email: draft.email);
      notifyListeners();
    }
    return message;
  }
}
