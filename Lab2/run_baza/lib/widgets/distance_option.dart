import 'package:flutter/material.dart';

import '../data/distance_profile.dart';
import 'race_motif.dart';
import '../data/mock_data.dart';
import '../data/race_motif.dart';

class DistanceOption extends StatelessWidget {
  final double distance;
  final Race race;
  final VoidCallback onTap;
  const DistanceOption({
    super.key,
    required this.distance,
    required this.race,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final s = t.colorScheme;
    final profile = DistanceProfile(distance);
    return Semantics(
      button: true,
      label: 'Открыть дистанцию ${profile.label}, ${race.locationLabel}',
      excludeSemantics: true,
      child: OutlinedButton(
        key: ValueKey('distance-${profile.number}'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          backgroundColor: profile.isHalf
              ? s.surfaceContainerHighest
              : s.primaryContainer,
          alignment: Alignment.centerLeft,
        ),
        onPressed: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(profile.label, style: t.textTheme.titleLarge),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_outward, size: 18, color: s.primary),
              ],
            ),
            RaceEmblem(motif: motifForRace(race, distance), height: 108),
            const SizedBox(height: 8),
            Text(race.locationLabel, style: t.textTheme.labelSmall),
            const SizedBox(height: 5),
            Text(
              motifName(motifForRace(race, distance)),
              style: t.textTheme.bodySmall?.copyWith(color: s.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
