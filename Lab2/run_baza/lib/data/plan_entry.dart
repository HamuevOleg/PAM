import 'json_fields.dart';
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

  factory PlanEntry.fromJson(Map<String, dynamic> j) => PlanEntry(
    jsonId(j['raceId']),
    j['reminderDays'] as int,
    id: jsonId(j['id']),
    distance: (j['distance'] as num?)?.toDouble(),
    pace: j['pace'] as String,
    visibility: j['visibility'] as String,
  );

  Map<String, Object?> toJson() => {
    'raceId': raceId,
    'reminderDays': reminderDays,
    'distance': distance,
    'pace': pace,
    'visibility': visibility,
  };

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
