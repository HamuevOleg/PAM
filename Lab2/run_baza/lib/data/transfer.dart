import 'entity.dart';

class TransferOffer implements Entity {
  @override
  final String id;
  final String raceId, driverName, departureTime, pickupPoint;
  final int freeSeats, contribution;
  final String departureCity, phone;
  const TransferOffer(
    this.id,
    this.raceId,
    this.driverName,
    this.departureTime,
    this.pickupPoint,
    this.freeSeats,
    this.contribution, {
    this.departureCity = 'Chișinău',
    this.phone = '',
  });

  TransferOffer copyWith({String? id, int? freeSeats}) => TransferOffer(
    id ?? this.id,
    raceId,
    driverName,
    departureTime,
    pickupPoint,
    freeSeats ?? this.freeSeats,
    contribution,
    departureCity: departureCity,
    phone: phone,
  );
}

class SeatRequest implements Entity {
  @override
  final String id;
  final String raceId, passengerName, pickupPoint;
  final int seats;
  final String departureCity, departureTime, phone;
  const SeatRequest(
    this.id,
    this.raceId,
    this.passengerName,
    this.seats,
    this.pickupPoint, {
    this.departureCity = 'Chișinău',
    this.departureTime = '',
    this.phone = '',
  });

  SeatRequest copyWith({String? id}) => SeatRequest(
    id ?? this.id,
    raceId,
    passengerName,
    seats,
    pickupPoint,
    departureCity: departureCity,
    departureTime: departureTime,
    phone: phone,
  );
}
