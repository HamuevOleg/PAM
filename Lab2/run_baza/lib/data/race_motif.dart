// Explicit event artwork: distance alone must never select a country.
enum RaceMotif {
  vineyard,
  arch,
  orhei,
  stefan,
  iasiPalace,
  athenaeum,
  forest,
  riverside,
  parkSteps,
}

String motifName(RaceMotif motif) => switch (motif) {
  RaceMotif.vineyard => 'Виноградники Крикова',
  RaceMotif.arch => 'Арка Кишинёва',
  RaceMotif.orhei => 'Старый Орхей',
  RaceMotif.stefan => 'Штефан чел Маре',
  RaceMotif.iasiPalace => 'Дворец культуры',
  RaceMotif.athenaeum => 'Румынский Атенеум',
  RaceMotif.forest => 'Лес Кодры',
  RaceMotif.riverside => 'Берега Днестра',
  RaceMotif.parkSteps => 'Парк Valea Morilor',
};
