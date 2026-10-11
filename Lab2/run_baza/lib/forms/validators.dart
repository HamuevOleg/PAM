/// Pure validation rules; keyboard filters are convenience, not validation.
abstract final class Validators {
  static String? name(String? value) {
    final length = (value ?? '').trim().length;
    return length < 2 || length > 60 ? 'Введите от 2 до 60 символов' : null;
  }

  static String? email(String? value) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch((value ?? '').trim())
      ? null
      : 'Введите e-mail, например runner@example.com';

  static String? password(String? value) =>
      (value ?? '').length >= 6 ? null : 'Не менее 6 символов';

  static String? phone(String? value) =>
      RegExp(r'^\+?[0-9]{8,15}$').hasMatch((value ?? '').trim())
      ? null
      : 'Введите 8–15 цифр, можно с + в начале';

  static String? seats(String? value) {
    final n = int.tryParse(value ?? '');
    return n == null || n < 1 || n > 8 ? 'От 1 до 8 мест' : null;
  }

  static String? price(String? value) {
    final n = int.tryParse(value ?? '');
    return n == null || n < 0 || n > 5000 ? 'От 0 до 5000 MDL' : null;
  }

  static String? time(String? value) =>
      RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$').hasMatch(value ?? '')
      ? null
      : 'Время в формате ЧЧ:ММ, например 06:30';

  static String? pace(String? value) {
    final match = RegExp(r'^(\d{1,2}):([0-5]\d)$').firstMatch(value ?? '');
    if (match != null) {
      final seconds = int.parse(match[1]!) * 60 + int.parse(match[2]!);
      if (seconds >= 180 && seconds <= 900) return null;
    }
    return 'Темп от 3:00 до 15:00 мин/км';
  }
}
