import 'exercises.dart';

void check(bool condition, String name) {
  if (!condition) throw StateError('FAILED: $name');
  print('PASS: $name');
}

Future<void> main() async {
  check(parseOrDefault('42', 0) == 42, 'E1 integer');
  check(parseOrDefault('abc', 0) == 0, 'E1 invalid');
  check(parseOrDefault(null, 7) == 7, 'E1 null');
  check(parseOrDefault('7.5', -1) == -1, 'E1 fractional');
  check(promotedAverage([9, 4, 7, 10, 3, 5]) == 7.75, 'E2 mixed');
  check((promotedAverage([10, 10, 9]) - 29 / 3).abs() < 1e-10, 'E2 all');
  check(promotedAverage([3, 4, 2]) == 0, 'E2 none');
  check(promotedAverage([]) == 0, 'E2 empty');
  check(formatPrice(12.5) == '12.50 MDL', 'E3 defaults');
  check(formatPrice(99.999, currency: 'EUR') == '100.00 EUR', 'E3 round');
  check(
    formatPrice(7.5, currency: 'USD', decimals: 1) == '7.5 USD',
    'E3 precision',
  );
  check(Student.guest().toString() == 'Student(Guest, —)', 'E4 guest');
  check(Student('A', 'G') != Student('A', 'H'), 'E4 difference');
  check({Student('A', 'G'), Student('A', 'G')}.length == 1, 'E4 hash');
  var eventLoopResponded = false;
  final timer = Future<void>.delayed(const Duration(milliseconds: 50), () {
    eventLoopResponded = true;
  });
  final watch = Stopwatch()..start();
  final profile = await fetchProfile('ana.rusu');
  await timer;
  check(eventLoopResponded, 'E6 event loop');
  check(watch.elapsedMilliseconds >= 1900, 'E6 delay');
  check(
    profile == 'Профиль: ana.rusu, группа TI-231, решено упражнений: 42',
    'E6 result',
  );
  print('All 17 checks passed. E5 output is shown in exercises.dart.');
}
