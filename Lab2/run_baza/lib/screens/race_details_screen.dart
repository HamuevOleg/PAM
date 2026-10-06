import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../widgets/design.dart';
import '../widgets/race_motif.dart';
import '../widgets/status_badge.dart';
import '../widgets/info_row.dart';
import 'transfer_screen.dart';
import 'distance_screen.dart';
import '../widgets/distance_option.dart';

class RaceDetailsScreen extends StatelessWidget {
  final Race race;
  const RaceDetailsScreen({super.key, required this.race});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final s = t.colorScheme;
    final canRegister = [
      'Boarding',
      'Last call',
      'On time',
    ].contains(race.status);
    return Scaffold(
      appBar: AppBar(
        title: Text(race.code),
        actions: [
          IconButton(
            tooltip: 'Сохранить забег',
            onPressed: () {},
            icon: const Icon(Icons.bookmark_outline),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
          decoration: BoxDecoration(
            color: s.surface,
            border: Border(top: BorderSide(color: s.outlineVariant)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Eyebrow('СТАРТОВЫЙ ВЗНОС'),
                    const SizedBox(height: 4),
                    Text(
                      '${race.fee} ${race.currency}',
                      style: t.textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: canRegister ? () {} : null,
                  child: Text(
                    canRegister ? 'Регистрация ↗' : 'Недоступно',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Eyebrow('${race.type} / ${race.locationLabel}'),
          const SizedBox(height: 14),
          Text(race.title, style: t.textTheme.headlineLarge),
          const SizedBox(height: 14),
          StatusBadge(status: race.status),
          const SizedBox(height: 24),
          CutPanel(
            color: s.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Eyebrow('${race.city} / ${race.code}')),
                    const Icon(Icons.north_east, size: 18),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            race.date.substring(0, 2),
                            style: t.textTheme.displaySmall?.copyWith(
                              fontSize: 66,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${race.date.substring(3)} / ${race.time}',
                            style: t.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RaceEmblem(motif: motifForRace(race), height: 150),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 14),
                Text(race.venue, style: t.textTheme.bodyMedium),
              ],
            ),
          ),
          const SectionHeading('01', 'Твои километры.'),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = MediaQuery.textScalerOf(context).scale(14) > 20
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final d in race.distances)
                    SizedBox(
                      width: width,
                      child: DistanceOption(
                        race: race,
                        distance: d,
                        onTap: () => openScreen(
                          context,
                          DistanceScreen(race: race, distance: d),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          InfoRow(
            label: 'Дата и старт',
            value: '${race.date} · ${race.time}',
            icon: Icons.schedule,
          ),
          InfoRow(
            label: 'Дорога из Кишинёва',
            value: '${race.distanceFromChisinau} км · ${race.city}',
            icon: Icons.route,
          ),
          const SectionHeading('02', 'До стартового выстрела.'),
          InfoRow(
            label: 'Место встречи',
            value: race.venue,
            icon: Icons.place_outlined,
          ),
          InfoRow(
            label: 'От организатора',
            value: race.organizerNote,
            icon: Icons.info_outline,
          ),
          const SectionHeading('03', 'Перед регистрацией'),
          CutPanel(
            color: s.tertiaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  race.discount,
                  style: t.textTheme.titleMedium?.copyWith(
                    color: s.onTertiaryContainer,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Условия участия и стоимость уточняйте у организатора.',
                  style: TextStyle(color: s.onTertiaryContainer),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(race.registrationUrl, style: t.textTheme.bodySmall),
          const SectionHeading('04', 'На старт — вместе.'),
          Text(
            'Найди попутчиков и раздели дорогу к новому личному рекорду.',
            style: t.textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => openScreen(context, TransferScreen(race: race)),
            icon: const Icon(Icons.directions_car_outlined),
            label: const Text('Найти попутчиков'),
          ),
        ],
      ),
    );
  }
}
