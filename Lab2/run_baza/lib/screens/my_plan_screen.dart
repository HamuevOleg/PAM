import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../widgets/design.dart';
import '../widgets/race_card.dart';
import 'race_details_screen.dart';

class MyPlanScreen extends StatelessWidget {
  const MyPlanScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Мой план')),
    body: ListView(
      padding: const EdgeInsets.all(22),
      children: [
        const Eyebrow('03 / ЛИЧНЫЙ СЕЗОН'),
        const SizedBox(height: 16),
        Text(
          'Большие планы.\nТвои старты.',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 24),
        CutPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Expanded(child: Metric('06', 'сохранённых забегов')),
                  Expanded(child: Metric('02', 'страны на карте')),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              const Eyebrow('БЛИЖАЙШЕЕ НАПОМИНАНИЕ'),
              const SizedBox(height: 8),
              Text(
                '02 октября · Orheiul Vechi Trail',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
        const SectionHeading('2026–27', 'Сохранённые старты'),
        for (final entry in plan)
          RaceCard(
            race: raceById(entry.raceId),
            reminder: 'Напомнить за ${entry.reminderDays} дн. до старта',
            onTap: () => openScreen(
              context,
              RaceDetailsScreen(race: raceById(entry.raceId)),
            ),
          ),
      ],
    ),
  );
}
