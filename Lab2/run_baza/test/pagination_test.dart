import 'package:flutter_test/flutter_test.dart';
import 'package:run_baza/models/collection_model.dart';
import 'package:run_baza/data/result.dart';

import 'state_model_test.dart' show DeferredRepository, Item;

void main() {
  test(
    'old page cannot append to a newer query; loadMore has a duplicate guard',
    () async {
      final repo = DeferredRepository(),
          model = CollectionModel<Item>(DeferredRepository());
      model.dispose();
      final state = CollectionModel<Item>(repo);
      final initial = state.load();
      repo.reads[0].complete(Ok(List.generate(20, (i) => Item('$i'))));
      await initial;
      expect(state.hasMore, isTrue);
      final more = state.loadMore();
      await state.loadMore();
      expect(repo.reads.length, 2);
      final search = state.load(search: 'new');
      repo.reads[2].complete(const Ok([Item('new')]));
      await search;
      repo.reads[1].complete(const Ok([Item('old-page')]));
      await more;
      expect(state.records.map((r) => r.id), ['new']);
      expect(state.loadingMore, isFalse);
      expect(state.hasMore, isFalse);
      state.dispose();
    },
  );
  test(
    'retry preserves query and a failed next page leaves current data',
    () async {
      final repo = DeferredRepository(),
          state = CollectionModel<Item>(DeferredRepository());
      state.dispose();
      final model = CollectionModel<Item>(repo);
      final load = model.load(search: 'Chișinău', country: 'moldova');
      repo.reads[0].complete(Ok(List.generate(20, (i) => Item('$i'))));
      await load;
      final more = model.loadMore();
      repo.reads[1].complete(const Err('offline'));
      await more;
      expect(model.count, 20);
      expect(model.moreError, 'offline');
      expect(model.hasMore, isTrue);
      final retry = model.load();
      repo.reads[2].complete(const Ok([]));
      await retry;
      expect(model.search, 'Chișinău');
      expect(model.country, 'moldova');
      model.dispose();
    },
  );
}
