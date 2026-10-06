import 'race_motif.dart';

enum RaceCountry {
  moldova('Молдова', 'MD'),
  romania('Румыния', 'RO');

  final String label, code;
  const RaceCountry(this.label, this.code);
}

// Учебные данные: даты, цены и участники вымышлены, это не афиша.
// Фиксированная дата сценария делает отчёт воспроизводимым.
const demoToday = '27.09.2026';
const daysToNextRace = 7;

class Race {
  final RaceCountry country;
  final RaceMotif artwork;
  String get locationLabel => '$city · ${country.label}';
  final String id, code, title, date, time, city, venue, season;
  final int distanceFromChisinau;
  final List<double> distances;
  final String type, status;
  final int fee;
  final String currency, discount, organizerNote, registrationUrl;
  const Race({
    required this.id,
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
    required this.distances,
    required this.type,
    required this.status,
    required this.fee,
    this.currency = 'MDL',
    required this.discount,
    required this.organizerNote,
    required this.registrationUrl,
  });
  String get distanceLabel => distances
      .map((d) => d == d.roundToDouble() ? d.toInt().toString() : d.toString())
      .join(' / ');
}

class TransferOffer {
  final String id, raceId, driverName, departureTime, pickupPoint;
  final int freeSeats, contribution;
  const TransferOffer(
    this.id,
    this.raceId,
    this.driverName,
    this.departureTime,
    this.pickupPoint,
    this.freeSeats,
    this.contribution,
  );
}

class SeatRequest {
  final String id, raceId, passengerName, pickupPoint;
  final int seats;
  const SeatRequest(
    this.id,
    this.raceId,
    this.passengerName,
    this.seats,
    this.pickupPoint,
  );
}

class PlanEntry {
  final String raceId;
  final int reminderDays;
  const PlanEntry(this.raceId, this.reminderDays);
}

const races = <Race>[
  Race(
    id: 'r1',
    country: RaceCountry.moldova,
    artwork: RaceMotif.orhei,
    code: 'RB 104',
    title: 'Orheiul Vechi Trail',
    date: '04.10.2026',
    time: '09:00',
    city: 'Trebujeni',
    venue: 'Площадь у моста, Trebujeni',
    season: 'Осень 2026',
    distanceFromChisinau: 58,
    distances: [10, 21.1],
    type: 'Trail',
    status: 'Boarding',
    fee: 450,
    discount: '−10% для команды от 5 человек',
    organizerNote: 'Выдача номеров с 07:30. Возьмите запас воды и ветровку.',
    registrationUrl: 'https://example.com/runbaza/r1',
  ),
  Race(
    id: 'r2',
    country: RaceCountry.moldova,
    artwork: RaceMotif.arch,
    code: 'RB 112',
    title: 'Chișinău City Half Marathon',
    date: '11.10.2026',
    time: '08:30',
    city: 'Chișinău',
    venue: 'Площадь Великого национального собрания',
    season: 'Осень 2026',
    distanceFromChisinau: 0,
    distances: [5, 10, 21.1],
    type: 'Road',
    status: 'Last call',
    fee: 600,
    discount: 'Студентам −15%',
    organizerNote: 'В стартовый пакет входит номер и электронный хронометраж.',
    registrationUrl: 'https://example.com/runbaza/r2',
  ),
  Race(
    id: 'r3',
    country: RaceCountry.romania,
    artwork: RaceMotif.iasiPalace,
    code: 'RB 126',
    title: 'Iași Autumn Run',
    date: '25.10.2026',
    time: '09:30',
    city: 'Iași',
    venue: 'Palatul Culturii',
    season: 'Осень 2026',
    distanceFromChisinau: 150,
    distances: [10, 21.1],
    type: 'Road',
    status: 'On time',
    fee: 150,
    currency: 'RON',
    discount: 'Ранняя регистрация',
    organizerNote: 'Для поездки подготовьте документы для пересечения границы.',
    registrationUrl: 'https://example.com/runbaza/r3',
  ),
  Race(
    id: 'r4',
    country: RaceCountry.moldova,
    artwork: RaceMotif.vineyard,
    code: 'RB 208',
    title: 'Cricova Wine Cellar Run',
    date: '08.11.2026',
    time: '10:00',
    city: 'Cricova',
    venue: 'Главный вход в винные подвалы',
    season: 'Осень 2026',
    distanceFromChisinau: 15,
    distances: [5, 10],
    type: 'Fun run',
    status: 'TBA',
    fee: 350,
    discount: 'Цена предварительная',
    organizerNote: 'Регистрация ещё не открыта. Точное расписание ожидается.',
    registrationUrl: 'https://example.com/runbaza/r4',
  ),
  Race(
    id: 'r5',
    country: RaceCountry.moldova,
    artwork: RaceMotif.forest,
    code: 'RB 214',
    title: 'Codrii Forest Night Trail',
    date: '14.11.2026',
    time: '18:00',
    city: 'Lozova',
    venue: 'Вход в заповедник Codrii',
    season: 'Осень 2026',
    distanceFromChisinau: 52,
    distances: [12, 24],
    type: 'Trail',
    status: 'Cancelled',
    fee: 400,
    discount: 'Возврат взноса организатором',
    organizerNote: 'Старт отменён. Регистрация закрыта.',
    registrationUrl: 'https://example.com/runbaza/r5',
  ),
  Race(
    id: 'r6',
    country: RaceCountry.moldova,
    artwork: RaceMotif.parkSteps,
    code: 'RB 305',
    title: 'Chișinău Winter Charity Run',
    date: '05.12.2026',
    time: '11:00',
    city: 'Chișinău',
    venue: 'Парк Valea Morilor, лестница',
    season: 'Зима 2026',
    distanceFromChisinau: 0,
    distances: [3, 5],
    type: 'Charity',
    status: 'Boarding',
    fee: 200,
    discount: 'Семейный билет 450 MDL',
    organizerNote: 'Благотворительный забег без соревновательного зачёта.',
    registrationUrl: 'https://example.com/runbaza/r6',
  ),
  Race(
    id: 'r7',
    country: RaceCountry.romania,
    artwork: RaceMotif.athenaeum,
    code: 'RB 411',
    title: 'București Spring Marathon',
    date: '11.04.2027',
    time: '08:00',
    city: 'București',
    venue: 'Piața Constituției',
    season: 'Весна 2027',
    distanceFromChisinau: 460,
    distances: [10, 21.1, 42.2],
    type: 'Road',
    status: 'TBA',
    fee: 250,
    currency: 'RON',
    discount: 'Тариф уточняется',
    organizerNote: 'Планируйте поездку накануне старта.',
    registrationUrl: 'https://example.com/runbaza/r7',
  ),
  Race(
    id: 'r8',
    country: RaceCountry.moldova,
    artwork: RaceMotif.riverside,
    code: 'RB 092',
    title: 'Nistru Riverside Run',
    date: '20.09.2026',
    time: '09:00',
    city: 'Vadul lui Vodă',
    venue: 'Набережная, центральный пляж',
    season: 'Архив 2026',
    distanceFromChisinau: 28,
    distances: [5, 10],
    type: 'Road',
    status: 'Departed',
    fee: 250,
    discount: 'Событие завершено',
    organizerNote: 'Событие завершено.',
    registrationUrl: 'https://example.com/runbaza/r8',
  ),
];

const offers = <TransferOffer>[
  TransferOffer('t1', 'r1', 'Andrei Rusu', '06:40', 'Chișinău · Circ', 3, 80),
  TransferOffer(
    't2',
    'r1',
    'Elena Munteanu',
    '06:50',
    'Chișinău · Botanica',
    2,
    90,
  ),
  TransferOffer(
    't3',
    'r1',
    'Victor Ceban',
    '06:30',
    'Chișinău · Buiucani',
    1,
    75,
  ),
  TransferOffer(
    't4',
    'r1',
    'Irina Lungu',
    '07:00',
    'Chișinău · Rîșcani',
    2,
    80,
  ),
  TransferOffer(
    't5',
    'r1',
    'Mihai Popa',
    '06:45',
    'Chișinău · Telecentru',
    3,
    85,
  ),
  TransferOffer('t6', 'r1', 'Ana Rotaru', '06:35', 'Chișinău · Centru', 1, 70),
];
const requests = <SeatRequest>[
  SeatRequest('s1', 'r1', 'Sergiu Moraru', 1, 'Chișinău · Centru'),
  SeatRequest('s2', 'r1', 'Daria Cojocaru', 2, 'Chișinău · Botanica'),
  SeatRequest('s3', 'r1', 'Pavel Ciobanu', 1, 'Chișinău · Buiucani'),
  SeatRequest('s4', 'r1', 'Alina Sîrbu', 1, 'Chișinău · Rîșcani'),
  SeatRequest('s5', 'r1', 'Cristian Negru', 2, 'Chișinău · Telecentru'),
  SeatRequest('s6', 'r1', 'Olga Marin', 1, 'Chișinău · Circ'),
];
const plan = <PlanEntry>[
  PlanEntry('r1', 2),
  PlanEntry('r2', 3),
  PlanEntry('r3', 7),
  PlanEntry('r4', 2),
  PlanEntry('r6', 1),
  PlanEntry('r7', 14),
];
Race raceById(String id) => races.firstWhere((r) => r.id == id);

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
