import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../widgets/design.dart';
import '../widgets/race_card.dart';
import 'race_details_screen.dart';

class RaceIndexScreen extends StatelessWidget {
  const RaceIndexScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Календарь забегов')),
    body: ListView.builder(
      padding: const EdgeInsets.all(22),
      itemCount: races.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('01 / НАЙТИ СОБЫТИЕ'),
              const SizedBox(height: 16),
              Text(
                'У каждого старта\nсвой характер.',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 24),
              const TextField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Забег, город или дистанция',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: Icon(Icons.tune, size: 20),
                ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final label in [
                      'Месяц',
                      'Дистанция',
                      'Город',
                      'Статус',
                      'Тип',
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: OutlinedButton(
                          onPressed: () {},
                          child: Row(
                            children: [
                              Text(label),
                              const Icon(Icons.expand_more, size: 16),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SectionHeading('08', 'Все события'),
            ],
          );
        }
        final race = races[index - 1];
        final newSeason = index == 1 || races[index - 2].season != race.season;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (newSeason)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Eyebrow(race.season),
              ),
            RaceCard(
              race: race,
              onTap: () => openScreen(context, RaceDetailsScreen(race: race)),
            ),
          ],
        );
      },
    ),
  );
}
