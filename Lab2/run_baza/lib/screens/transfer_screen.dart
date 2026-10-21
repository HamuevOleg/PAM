import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';

import '../models/race_catalog.dart';
import '../models/transfer_models.dart';
import '../widgets/data_status.dart';
import 'not_found_screen.dart';
import '../widgets/design.dart';
import '../widgets/event_glyph.dart';

class TransferScreen extends StatelessWidget {
  final String id;
  const TransferScreen({super.key, required this.id});
  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<RaceCatalog>();
    final offerModel = context.watch<OfferModel>();
    final requestModel = context.watch<RequestModel>();
    final state = dataScreenState(context, 'Трансфер', [
      catalog,
      offerModel,
      requestModel,
    ]);
    if (state != null) return state;
    final offers = offerModel.records;
    final requests = requestModel.records;
    final race = catalog.byId(id);
    if (race == null) return const NotFoundScreen();
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
                onPressed: () => context.push('/transfers/$id/offer'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Я водитель'),
              ),
              OutlinedButton(
                onPressed: () => context.push('/transfers/$id/request'),
                child: const Text('Ищу место'),
              ),
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
              key: ValueKey(driver.id),
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
                        Expanded(
                          child: Text(
                            '${driver.departureCity} · ${driver.pickupPoint}',
                          ),
                        ),
                      ],
                    ),
                    if (driver.phone.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(driver.phone),
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
                          onPressed: () =>
                              context.push('/transfers/$id/request'),
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
              key: ValueKey(passenger.id),
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  leading: const Icon(Icons.person_outline),
                  title: Text(passenger.passengerName),
                  subtitle: Text(
                    '${passenger.departureCity} · ${passenger.pickupPoint} · мест: ${passenger.seats}\n${passenger.departureTime} ${passenger.phone}',
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
