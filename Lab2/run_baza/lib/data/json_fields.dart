String jsonId(Object? value) {
  if (value is String && value.isNotEmpty) return value;
  if (value is int) return value.toString();
  throw const FormatException('Missing or invalid ID');
}

T jsonEnum<T extends Enum>(List<T> values, Object? value) {
  for (final item in values) {
    if (item.name == value) return item;
  }
  throw const FormatException('Unknown enum value');
}
