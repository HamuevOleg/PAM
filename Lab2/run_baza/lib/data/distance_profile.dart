// Presentation copy only. Race logistics come from the selected Race object.
class DistanceProfile {
  final double kilometers;
  const DistanceProfile(this.kilometers);

  String get number => kilometers == kilometers.roundToDouble()
      ? kilometers.toInt().toString()
      : kilometers.toString();
  String get label => '$number км';
  bool get isHalf => kilometers >= 21 && kilometers < 22;
  String get name => isHalf
      ? 'Полумарафон'
      : kilometers == 10
      ? 'Десятка'
      : kilometers >= 42
      ? 'Марафон'
      : kilometers == 5
      ? 'Пятёрка'
      : 'Твоя дистанция';
  String get headline => isHalf
      ? 'Половина марафона.\nЦелая история.'
      : kilometers == 10
      ? 'Твой ритм.\nТвоя десятка.'
      : 'Каждый километр\nимеет значение.';
  String get description => isHalf
      ? 'От первого шага до финишной черты. Дистанция, в которой есть место и характеру, и эмоциям.'
      : kilometers == 10
      ? 'Десять километров, чтобы почувствовать атмосферу старта, найти свой ритм и написать собственную историю финиша.'
      : 'Новый старт, знакомое чувство движения. Выбери свою дистанцию и проживи её в своём темпе.';
}
