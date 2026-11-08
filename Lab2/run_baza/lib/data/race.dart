import 'json_fields.dart';
import 'entity.dart';
import 'race_motif.dart';

enum RaceCountry {
  moldova('Молдова', 'MD'),
  romania('Румыния', 'RO');

  final String label, code;
  const RaceCountry(this.label, this.code);
}

class Race implements Entity {
  final double? previewDistance;
  final RaceCountry country;
  final RaceMotif artwork;
  String get locationLabel => '$city · ${country.label}';
  @override
  final String id;
  final String code, title, date, time, city, venue, season;
  final int distanceFromChisinau;
  final List<double> _distances;
  List<double> get distances => List.unmodifiable(_distances);
  final String type, status;
  final int fee;
  final String currency, discount, organizerNote, registrationUrl;
  const Race({
    required this.id,
    this.previewDistance,
    required this.code,
    required this.title,
    required this.date,
    required this.time,
    required this.city,
    required this.country,
    required this.artwork,
    required this.venue,
    required this.season,
    required this.distanceFromChisinau,
    required this._distances,
    required this.type,
    required this.status,
    required this.fee,
    this.currency = 'MDL',
    required this.discount,
    required this.organizerNote,
    required this.registrationUrl,
  });

  factory Race.fromJson(Map<String, dynamic> j) => Race(
    id: jsonId(j['id']),
    previewDistance: (j['previewDistance'] as num?)?.toDouble(),
    country: jsonEnum(RaceCountry.values, j['country']),
    artwork: jsonEnum(RaceMotif.values, j['artwork']),
    code: j['code'] as String,
    title: j['title'] as String,
    date: j['date'] as String,
    time: j['time'] as String,
    city: j['city'] as String,
    venue: j['venue'] as String,
    season: j['season'] as String,
    distanceFromChisinau: j['distanceFromChisinau'] as int,
    distances: (j['distances'] as List)
        .map((v) => (v as num).toDouble())
        .toList(),
    type: j['type'] as String,
    status: j['status'] as String,
    fee: j['fee'] as int,
    currency: j['currency'] as String,
    discount: j['discount'] as String,
    organizerNote: j['organizerNote'] as String,
    registrationUrl: j['registrationUrl'] as String,
  );

  Map<String, Object?> toJson() => {
    'previewDistance': previewDistance,
    'country': country.name,
    'artwork': artwork.name,
    'code': code,
    'title': title,
    'date': date,
    'time': time,
    'city': city,
    'venue': venue,
    'season': season,
    'distanceFromChisinau': distanceFromChisinau,
    'distances': distances,
    'type': type,
    'status': status,
    'fee': fee,
    'currency': currency,
    'discount': discount,
    'organizerNote': organizerNote,
    'registrationUrl': registrationUrl,
  };

  Race copyWith({String? id}) => Race(
    id: id ?? this.id,
    previewDistance: previewDistance,
    code: code,
    title: title,
    date: date,
    time: time,
    city: city,
    country: country,
    artwork: artwork,
    venue: venue,
    season: season,
    distanceFromChisinau: distanceFromChisinau,
    distances: distances,
    type: type,
    status: status,
    fee: fee,
    currency: currency,
    discount: discount,
    organizerNote: organizerNote,
    registrationUrl: registrationUrl,
  );
  String get distanceLabel => distances
      .map((d) => d == d.roundToDouble() ? d.toInt().toString() : d.toString())
      .join(' / ');
}

// A longer Chișinău city race gets a second local landmark. Other events
// retain their own setting at every distance, including cross-border races.
RaceMotif motifForRace(Race race, [double? distance]) =>
    race.country == RaceCountry.moldova &&
        race.city == 'Chișinău' &&
        race.artwork == RaceMotif.arch &&
        distance != null &&
        distance >= 20
    ? RaceMotif.stefan
    : race.artwork;
