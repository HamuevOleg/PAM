import 'package:flutter/material.dart';

import '../data/distance_profile.dart';
import '../data/mock_data.dart';
import '../widgets/design.dart';
import '../widgets/animated_route.dart';
import '../widgets/info_row.dart';
import '../widgets/status_badge.dart';
import 'transfer_screen.dart';

class DistanceScreen extends StatelessWidget {
  final Race race;
  final double distance;
  const DistanceScreen({super.key, required this.race, required this.distance});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final s = t.colorScheme;
    final profile = DistanceProfile(distance);
    return Scaffold(
      appBar: AppBar(
        title: Text(profile.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 22),
            child: Center(child: Eyebrow(race.code)),
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
          child: FilledButton.icon(
            onPressed: () => openScreen(context, TransferScreen(race: race)),
            icon: const Icon(Icons.directions_car_outlined, size: 21),
            label: const Text(
              'На старт с попутчиками',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
        children: [
          Eyebrow('ДИСТАНЦИЯ / ${race.type}'),
          const SizedBox(height: 16),
          CutPanel(
            color: profile.isHalf
                ? s.surfaceContainerHighest
                : s.surfaceContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Eyebrow(profile.name)),
                    Icon(Icons.north_east, color: s.primary, size: 20),
                  ],
                ),
                const SizedBox(height: 22),
                Semantics(
                  label: profile.label,
                  excludeSemantics: true,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            profile.number,
                            style: t.textTheme.displaySmall?.copyWith(
                              fontSize: profile.isHalf ? 104 : 120,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -6,
                              color: s.primary,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 10),
                        child: Text(
                          'КМ',
                          style: t.textTheme.titleMedium?.copyWith(
                            color: s.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRoute(
                  distance: distance,
                  motif: motifForRace(race, distance),
                ),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        race.locationLabel,
                        style: t.textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(race.date, style: t.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Text(profile.headline, style: t.textTheme.headlineLarge),
          const SizedBox(height: 14),
          Text(
            profile.description,
            style: t.textTheme.bodyLarge?.copyWith(color: s.onSurfaceVariant),
          ),
          const SectionHeading('01', 'Твой старт'),
          Text(race.title, style: t.textTheme.titleLarge),
          const SizedBox(height: 12),
          StatusBadge(status: race.status),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final wideText = MediaQuery.textScalerOf(context).scale(14) > 20;
              final width = wideText
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: width,
                    child: _Fact(
                      icon: Icons.schedule,
                      label: 'СТАРТ СОБЫТИЯ',
                      value: race.time,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _Fact(
                      icon: Icons.route,
                      label: 'ФОРМАТ',
                      value: race.type == 'Trail'
                          ? 'Трейл'
                          : race.type == 'Road'
                          ? 'Шоссе'
                          : race.type,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          InfoRow(
            label: 'Место встречи',
            value: race.venue,
            icon: Icons.place_outlined,
          ),
          InfoRow(
            label: 'Из Кишинёва',
            value: '${race.distanceFromChisinau} км до ${race.city}',
            icon: Icons.directions_car_outlined,
          ),
          const SectionHeading('02', 'До линии старта'),
          _Checklist(
            number: '01',
            title: 'Проверь детали',
            text: race.organizerNote,
          ),
          const _Checklist(
            number: '02',
            title: 'Собери всё заранее',
            text: 'Номер участника, привычная экипировка и вещи для переодевания после финиша.',
          ),
          const _Checklist(
            number: '03',
            title: 'Продумай дорогу',
            text: 'Уточни точку встречи и договорись с попутчиками о времени выезда.',
          ),
          const SectionHeading('03', 'Участие в событии'),
          CutPanel(
            color: s.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('ВЗНОС, УКАЗАННЫЙ ДЛЯ ЗАБЕГА'),
                const SizedBox(height: 12),
                Text(
                  '${race.fee} ${race.currency}',
                  style: t.textTheme.headlineLarge?.copyWith(color: s.primary),
                ),
                const SizedBox(height: 12),
                Text(race.discount),
                const SizedBox(height: 14),
                Text(
                  'Тариф и условия для выбранной дистанции уточняются у организатора.',
                  style: t.textTheme.bodySmall?.copyWith(
                    color: s.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Вернуться к забегу'),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _Fact({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return CutPanel(
      color: t.colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: t.colorScheme.primary, size: 23),
          const SizedBox(height: 18),
          Eyebrow(label),
          const SizedBox(height: 8),
          Text(value, style: t.textTheme.headlineMedium),
        ],
      ),
    );
  }
}

class _Checklist extends StatelessWidget {
  final String number, title, text;
  const _Checklist({
    required this.number,
    required this.title,
    required this.text,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Text(number, style: Theme.of(context).textTheme.labelSmall),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 7),
              Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
