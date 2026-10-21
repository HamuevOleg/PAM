import 'entity.dart';

enum AppAppearance { system, light, dark }

class RunnerProfile implements Entity {
  @override
  final String id;
  final String name, email, city, pace, bio;
  final double preferredDistance;
  final int seasonGoal, avatar;
  final AppAppearance appearance;
  final bool publicPlan;
  const RunnerProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.city,
    required this.pace,
    required this.bio,
    required this.preferredDistance,
    required this.seasonGoal,
    this.avatar = 0,
    this.appearance = AppAppearance.system,
    this.publicPlan = false,
  });

  RunnerProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? city,
    String? pace,
    String? bio,
    double? preferredDistance,
    int? seasonGoal,
    int? avatar,
    AppAppearance? appearance,
    bool? publicPlan,
  }) => RunnerProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    city: city ?? this.city,
    pace: pace ?? this.pace,
    bio: bio ?? this.bio,
    preferredDistance: preferredDistance ?? this.preferredDistance,
    seasonGoal: seasonGoal ?? this.seasonGoal,
    avatar: avatar ?? this.avatar,
    appearance: appearance ?? this.appearance,
    publicPlan: publicPlan ?? this.publicPlan,
  );
}
