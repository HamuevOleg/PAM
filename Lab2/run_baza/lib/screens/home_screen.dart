import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../widgets/design.dart';
import '../widgets/race_motif.dart';
import '../widgets/distance_option.dart';
import 'distance_screen.dart';
import '../widgets/race_card.dart';
import '../widgets/status_badge.dart';
import 'login_screen.dart';
import 'race_index_screen.dart';
import 'race_details_screen.dart';
import 'transfer_screen.dart';
import 'my_plan_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final s = t.colorScheme;
    final next = races.first;
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
            tooltip: 'Вход',
            onPressed: () => openScreen(context, const LoginScreen()),
            icon: const Icon(Icons.person_outline),
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: s.surface,
            border: Border(top: BorderSide(color: s.outlineVariant)),
          ),
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
          child: Row(
            children: [
              _nav(context, 'Главная', Icons.grid_view, null, true),
              _nav(
                context,
                'Забеги',
                Icons.calendar_month_outlined,
                const RaceIndexScreen(),
              ),
              _nav(
                context,
                'Попутки',
                Icons.directions_car_outlined,
                TransferScreen(race: next),
              ),
              _nav(
                context,
                'Мой план',
                Icons.bookmark_outline,
                const MyPlanScreen(),
              ),
              _nav(context, 'Профиль', Icons.tune, const SettingsScreen()),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 12),
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
              const Expanded(child: Metric('08', 'забегов в календаре')),
              Expanded(
                child: Metric(
                  '${offers.fold<int>(0, (n, o) => n + o.freeSeats)}',
                  'мест в попутках',
                ),
              ),
              const Icon(Icons.south_east, size: 30),
            ],
          ),
          const SectionHeading('01', 'Ближайший старт'),
          CutPanel(
            color: s.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Eyebrow('${next.code} / TRAIL')),
                    const Eyebrow('ЧЕРЕЗ 7 ДНЕЙ'),
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
                            '04',
                            style: t.textTheme.displaySmall?.copyWith(
                              fontSize: 66,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Eyebrow('ОКТЯБРЯ / 09:00'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RaceEmblem(motif: motifForRace(next), height: 135),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Trebujeni · 10 / 21.1 км',
                  style: t.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                StatusBadge(status: next.status),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () =>
                        openScreen(context, RaceDetailsScreen(race: next)),
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
            onTap: () => openScreen(context, TransferScreen(race: next)),
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
                        Text('Попутчики из Кишинёва'),
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
                  for (final (race, d) in [
                    (raceById('r4'), 5.0),
                    (raceById('r3'), 10.0),
                    (raceById('r1'), 21.1),
                    (raceById('r7'), 42.2),
                  ])
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
          SectionHeading(
            '03',
            'Календарь',
            trailing: TextButton(
              onPressed: () => openScreen(context, const RaceIndexScreen()),
              child: const Text('Все 8 →'),
            ),
          ),
          for (final race in races)
            RaceCard(
              race: race,
              onTap: () => openScreen(context, RaceDetailsScreen(race: race)),
            ),
        ],
      ),
    );
  }

  Widget _nav(
    BuildContext context,
    String label,
    IconData icon,
    Widget? page, [
    bool active = false,
  ]) {
    final s = Theme.of(context).colorScheme;
    return Expanded(
      child: Semantics(
        selected: active,
        child: InkWell(
          onTap: page == null ? null : () => openScreen(context, page),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 21,
                  color: active ? s.primary : s.onSurfaceVariant,
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? s.primary : s.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
