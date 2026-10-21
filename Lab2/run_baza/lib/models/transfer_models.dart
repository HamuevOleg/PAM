import '../data/offer_repository.dart';
import '../data/request_repository.dart';
import '../data/transfer.dart';
import 'collection_model.dart';

class OfferModel extends CollectionModel<TransferOffer> {
  OfferModel(OfferRepository repository) : super(repository);
}

class RequestModel extends CollectionModel<SeatRequest> {
  RequestModel(RequestRepository repository) : super(repository);
}
