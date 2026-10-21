import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';

import '../data/race.dart';
import '../models/race_catalog.dart';
import '../models/plan_model.dart';
import '../widgets/plan_actions.dart';
import '../widgets/data_status.dart';
import 'not_found_screen.dart';
import '../widgets/design.dart';
import '../widgets/race_motif.dart';
import '../widgets/status_badge.dart';
import '../widgets/info_row.dart';
import '../widgets/distance_option.dart';

class RaceDetailsScreen extends StatelessWidget {
  final String id;
  const RaceDetailsScreen({super.key, required this.id});
  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<RaceCatalog>();
    final plan = context.watch<PlanModel>();
    final entry = plan.forRace(id);
    final state = dataScreenState(context, 'Забег', [catalog, plan]);
    if (state != null) return state;
    final race = catalog.byId(id);
    if (race == null) return const NotFoundScreen();
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
            tooltip: 'Мой старт',
            onPressed: () => context.push('/races/$id/participate'),
            icon: Icon(entry == null ? Icons.bookmark_outline : Icons.bookmark),
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
                  onPressed: canRegister
                      ? () => context.push('/races/$id/participate')
                      : null,
                  child: Text(
                    canRegister ? 'Я бегу →' : 'Недоступно',
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
          if (entry != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'В твоём плане · ${entry.distance ?? "?"} км',
                      key: const Key('race-in-plan'),
                      style: t.textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    key: const Key('details-remove-plan'),
                    tooltip: 'Убрать из плана',
                    onPressed: plan.isSaving
                        ? null
                        : () => removeFromPlan(context, entry),
                    icon: plan.isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.bookmark_remove_outlined),
                  ),
                ],
              ),
            ),
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
                        onTap: () =>
                            context.push('/races/${race.id}/distance/$d'),
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
            onPressed: () => context.push('/transfers/${race.id}'),
            icon: const Icon(Icons.directions_car_outlined),
            label: const Text('Найти попутчиков'),
          ),
        ],
      ),
    );
  }
}
