import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';

import '../data/race.dart';
import '../models/race_catalog.dart';
import '../models/transfer_models.dart';
import '../widgets/data_status.dart';
import '../widgets/design.dart';
import '../widgets/race_motif.dart';
import '../widgets/distance_option.dart';
import '../widgets/race_card.dart';
import '../widgets/status_badge.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final s = t.colorScheme;
    final catalog = context.watch<RaceCatalog>();
    final transfers = context.watch<OfferModel>();
    final state = dataScreenState(context, 'RUNBAZA', [catalog, transfers]);
    if (state != null) return state;
    final races = catalog.records;
    final offers = transfers.records;
    if (races.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('RUNBAZA')),
        body: const Center(child: Text('В календаре пока нет забегов.')),
      );
    }
    final next = races.first;
    final featured = races.where((r) => r.previewDistance != null).toList()
      ..sort((a, b) => a.previewDistance!.compareTo(b.previewDistance!));
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.route, color: s.primary, size: 27),
            const SizedBox(width: 8),
            const Text(
              'RUNBAZA',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Профиль',
            onPressed: () => context.go('/profile'),
            icon: const Icon(Icons.person_outline),
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            context.read<RaceCatalog>().load(),
            context.read<OfferModel>().load(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 12),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Row(
              children: [
                Container(width: 6, height: 6, color: s.tertiary),
                const SizedBox(width: 8),
                const Expanded(child: Eyebrow('МОЛДОВА + РУМЫНИЯ / 26–27')),
                const Eyebrow('RU'),
              ],
            ),
            const SizedBox(height: 22),
            Text('ТВОЙ СЛЕДУЮЩИЙ', style: t.textTheme.displaySmall),
            Text(
              'СТАРТ.',
              style: t.textTheme.displaySmall?.copyWith(color: s.primary),
            ),
            const SizedBox(height: 14),
            Text(
              'Ближе к бегу. Ближе друг к другу.',
              style: t.textTheme.bodyLarge?.copyWith(color: s.onSurfaceVariant),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: Metric(
                    '${races.length}'.padLeft(2, '0'),
                    'забегов в календаре',
                  ),
                ),
                Expanded(
                  child: Metric(
                    '${offers.fold<int>(0, (n, o) => n + o.freeSeats)}',
                    'мест в попутках',
                  ),
                ),
                const Icon(Icons.south_east, size: 30),
              ],
            ),
            const SectionHeading('01', 'Старт в фокусе'),
            CutPanel(
              color: s.surfaceContainerHighest,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Eyebrow('${next.code} / ${next.type}')),
                      Eyebrow(next.date),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(next.title, style: t.textTheme.headlineMedium),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              next.date.split('.').first,
                              style: t.textTheme.displaySmall?.copyWith(
                                fontSize: 66,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Eyebrow('${next.date.substring(3)} / ${next.time}'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: RaceEmblem(
                          motif: motifForRace(next),
                          height: 135,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    '${next.city} · ${next.distanceLabel} км',
                    style: t.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  StatusBadge(status: next.status),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => context.push('/races/${next.id}'),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('Открыть забег')),
                          Icon(Icons.arrow_outward, size: 19),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => context.push('/transfers/${next.id}'),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Icon(Icons.directions_car_outlined, color: s.primary),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'На старт — вместе',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text('Поездки и запросы на место'),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
            const SectionHeading('02', 'Города и дистанции'),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = MediaQuery.textScalerOf(context).scale(14) > 20
                    ? constraints.maxWidth
                    : (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final race in featured)
                      SizedBox(
                        width: width,
                        child: DistanceOption(
                          race: race,
                          distance: race.previewDistance!,
                          onTap: () => context.push(
                            '/races/${race.id}/distance/${race.previewDistance!}',
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            SectionHeading(
              '03',
              'Календарь',
              trailing: TextButton(
                onPressed: () => context.go('/races'),
                child: Text('Все ${races.length}'),
              ),
            ),
            for (final race in races)
              RaceCard(
                race: race,
                onTap: () => context.push('/races/${race.id}'),
              ),
          ],
        ),
      ),
    );
  }
}
