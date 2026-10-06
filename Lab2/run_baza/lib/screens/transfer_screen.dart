import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../widgets/design.dart';
import '../widgets/event_glyph.dart';

class TransferScreen extends StatelessWidget {
  final Race race;
  const TransferScreen({super.key, required this.race});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final s = t.colorScheme;
    final drivers = offers.where((o) => o.raceId == race.id).toList();
    final passengers = requests.where((o) => o.raceId == race.id).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Трансфер')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const Eyebrow('02 / ПОПУТЧИКИ'),
          const SizedBox(height: 16),
          Text(
            'Раздели дорогу.\nРаздели эмоции.',
            style: t.textTheme.headlineLarge,
          ),
          const SizedBox(height: 24),
          CutPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow('${race.date} / ${race.code}'),
                const SizedBox(height: 14),
                Text('Chișinău → ${race.city}', style: t.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(race.title),
                const SizedBox(height: 18),
                const Divider(),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Metric(
                        '${race.distanceFromChisinau} км',
                        'в одну сторону',
                      ),
                    ),
                    Expanded(
                      child: Metric(
                        '${drivers.fold<int>(0, (n, o) => n + o.freeSeats)}',
                        'свободных мест',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Я водитель'),
              ),
              OutlinedButton(onPressed: () {}, child: const Text('Ищу место')),
            ],
          ),
          SectionHeading(
            drivers.length.toString().padLeft(2, '0'),
            'Едем вместе',
          ),
          if (drivers.isEmpty)
            CutPanel(
              child: Column(
                children: [
                  const EventGlyph(kind: 'course', height: 110),
                  Text('Попутчиков пока нет', style: t.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text(
                    'Стань первым: предложи поездку или оставь запрос на место.',
                  ),
                ],
              ),
            ),
          for (final driver in drivers)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: CutPanel(
                color: s.surfaceContainerLow,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: s.primaryContainer,
                          foregroundColor: s.primary,
                          child: Text(
                            driver.driverName
                                .split(' ')
                                .map((n) => n[0])
                                .join(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driver.driverName,
                                style: t.textTheme.titleMedium,
                              ),
                              Text(
                                '${driver.freeSeats} ${driver.freeSeats == 1 ? 'свободное место' : 'свободных места'}',
                                style: t.textTheme.bodySmall?.copyWith(
                                  color: s.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.departureTime,
                          style: t.textTheme.titleLarge,
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: Text(driver.pickupPoint)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${driver.contribution} MDL / чел.',
                          style: t.textTheme.titleMedium,
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Запросить место ↗'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          SectionHeading(
            passengers.length.toString().padLeft(2, '0'),
            'Ищут место',
          ),
          if (passengers.isEmpty)
            const Text('Пока нет запросов. Можно оставить первый.'),
          for (final passenger in passengers)
            Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  leading: const Icon(Icons.person_outline),
                  title: Text(passenger.passengerName),
                  subtitle: Text(
                    '${passenger.pickupPoint} · мест: ${passenger.seats}',
                  ),
                ),
                const Divider(),
              ],
            ),
          const SizedBox(height: 24),
          Text(
            'Договоритесь о месте встречи и времени выезда заранее.',
            style: t.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
