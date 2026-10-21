import 'entity.dart';

class PlanEntry implements Entity {
  @override
  final String id;
  final String raceId;
  final int reminderDays;
  final double? distance;
  final String pace, visibility;
  const PlanEntry(
    this.raceId,
    this.reminderDays, {
    String? id,
    this.distance,
    this.pace = '6:00',
    this.visibility = 'private',
  }) : id = id ?? raceId;

  PlanEntry copyWith({
    String? id,
    int? reminderDays,
    double? distance,
    String? pace,
    String? visibility,
  }) => PlanEntry(
    raceId,
    reminderDays ?? this.reminderDays,
    id: id ?? this.id,
    distance: distance ?? this.distance,
    pace: pace ?? this.pace,
    visibility: visibility ?? this.visibility,
  );
}
