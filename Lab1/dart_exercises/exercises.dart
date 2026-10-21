// Lab 1. Hamuev Oleg, CR-232.
// Run: dart run exercises.dart

// E1: tryParse returns null on invalid input; ?? provides a fallback.
int parseOrDefault(String? input, int fallback) =>
    int.tryParse(input ?? '') ?? fallback;

// E2: filter grades and sum them without explicit loops.
double promotedAverage(List<int> grades) {
  final promoted = grades.where((grade) => grade >= 5);
  return promoted.isEmpty
      ? 0.0
      : promoted.fold<int>(0, (sum, grade) => sum + grade) / promoted.length;
}

// E3: optional named parameters can be omitted or supplied by name.
String formatPrice(
  double amount, {
  String currency = 'MDL',
  int decimals = 2,
}) => '${amount.toStringAsFixed(decimals)} $currency';

// E4: immutable fields and value equality.
class Student {
  final String name;
  final String group;

  const Student(this.name, this.group);
  const Student.guest() : this('Guest', '—');

  @override
  String toString() => 'Student($name, $group)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Student && other.name == name && other.group == group;

  @override
  int get hashCode => Object.hash(name, group);
}

// E5: share a method between classes using a mixin.
mixin Loggable {
  void log(String msg) => print('[$runtimeType] $msg');
}

class CartService with Loggable {
  void addItem(String item) => log('товар добавлен: $item');
}

class AuthService with Loggable {
  void login(String username) => log('пользователь вошёл: $username');
}

// E6: awaiting a Future does not block the Dart event loop.
Future<String> fetchProfile(String username) async {
  await Future<void>.delayed(const Duration(seconds: 2));
  return 'Профиль: $username, группа TI-231, решено упражнений: 42';
}

Future<void> main() async {
  print('E1');
  print(parseOrDefault('42', 0));
  print(parseOrDefault('abc', 0));
  print(parseOrDefault(null, 7));
  print(parseOrDefault('7.5', -1));

  print('\nE2');
  print(promotedAverage([9, 4, 7, 10, 3, 5]));
  print(promotedAverage([10, 10, 9]));
  print(promotedAverage([3, 4, 2]));

  print('\nE3');
  print(formatPrice(12.5));
  print(formatPrice(12.5, currency: 'MDL'));
  print(formatPrice(99.999, currency: 'EUR'));
  print(formatPrice(7.5, currency: 'USD', decimals: 1));

  print('\nE4');
  print(Student('Ana Rusu', 'TI-231'));
  print(Student.guest());
  print(Student('Ana Rusu', 'TI-231') == Student('Ana Rusu', 'TI-231'));
  print({Student('Ana Rusu', 'TI-231'), Student('Ana Rusu', 'TI-231')}.length);

  print('\nE5');
  CartService().addItem('Paracetamol');
  AuthService().login('ana.rusu');

  print('\nE6');
  print('Загружается профиль пользователя ana.rusu...');
  final profile = await fetchProfile('ana.rusu');
  print(profile);
  print('Готово.');
}
