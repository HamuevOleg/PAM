import 'json_fields.dart';
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

  factory TransferOffer.fromJson(Map<String, dynamic> j) => TransferOffer(
    jsonId(j['id']),
    jsonId(j['raceId']),
    j['driverName'] as String,
    j['departureTime'] as String,
    j['pickupPoint'] as String,
    j['freeSeats'] as int,
    j['contribution'] as int,
    departureCity: j['departureCity'] as String,
    phone: j['phone'] as String,
  );

  Map<String, Object?> toJson() => {
    'raceId': raceId,
    'driverName': driverName,
    'departureTime': departureTime,
    'pickupPoint': pickupPoint,
    'freeSeats': freeSeats,
    'contribution': contribution,
    'departureCity': departureCity,
    'phone': phone,
  };

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

  factory SeatRequest.fromJson(Map<String, dynamic> j) => SeatRequest(
    jsonId(j['id']),
    jsonId(j['raceId']),
    j['passengerName'] as String,
    j['seats'] as int,
    j['pickupPoint'] as String,
    departureCity: j['departureCity'] as String,
    departureTime: j['departureTime'] as String,
    phone: j['phone'] as String,
  );

  Map<String, Object?> toJson() => {
    'raceId': raceId,
    'passengerName': passengerName,
    'seats': seats,
    'pickupPoint': pickupPoint,
    'departureCity': departureCity,
    'departureTime': departureTime,
    'phone': phone,
  };

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
