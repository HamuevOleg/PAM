import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import 'design.dart';
import 'race_motif.dart';
import 'status_badge.dart';

class RaceCard extends StatelessWidget {
  final Race race;
  final VoidCallback? onTap;
  final String? reminder;
  const RaceCard({super.key, required this.race, this.onTap, this.reminder});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final s = t.colorScheme;
    final ground = race.type == 'Trail'
        ? s.surfaceContainerHighest
        : race.type == 'Fun run'
        ? s.tertiaryContainer
        : s.surfaceContainer;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CutPanel(
            color: ground,
            padding: EdgeInsets.zero,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Eyebrow('${race.date} / ${race.code}'),
                          ),
                          Icon(
                            reminder != null
                                ? Icons.bookmark
                                : Icons.arrow_outward,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Eyebrow(race.type),
                      const SizedBox(height: 6),
                      Text(race.title, style: t.textTheme.headlineMedium),
                      RaceEmblem(motif: motifForRace(race), height: 170),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 16),
                          const SizedBox(width: 4),
                          Expanded(child: Text(race.locationLabel)),
                          Expanded(
                            child: Text(
                              '${race.distanceFromChisinau} км от Кишинёва',
                              textAlign: TextAlign.right,
                              style: t.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          CutPanel(
            color: ground,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 18,
                  runSpacing: 6,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Text(
                      '${race.distanceLabel} км',
                      style: t.textTheme.titleMedium,
                    ),
                    Text(
                      '${race.fee} ${race.currency}',
                      style: t.textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                StatusBadge(status: race.status),
                if (reminder != null) ...[
                  const SizedBox(height: 12),
                  Text(reminder!, style: t.textTheme.bodySmall),
                ],
                const SizedBox(height: 12),
                const Divider(),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: onTap,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('Подробнее о старте')),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
