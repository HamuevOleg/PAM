import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/race_catalog.dart';
import '../models/plan_model.dart';
import '../widgets/design.dart';
import '../widgets/race_card.dart';
import '../widgets/data_status.dart';
import '../widgets/plan_actions.dart';

class MyPlanScreen extends StatelessWidget {
  const MyPlanScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<RaceCatalog>();
    final model = context.watch<PlanModel>();
    final state = dataScreenState(context, 'Мой план', [catalog, model]);
    if (state != null) return state;
    final entries = model.records
        .where((e) => catalog.byId(e.raceId) != null)
        .toList();
    final km = entries.fold<double>(0, (total, e) => total + (e.distance ?? 0));
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой план'),
        actions: [
          IconButton(
            tooltip: 'Обновить план',
            onPressed: () => context.read<PlanModel>().load(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const Eyebrow('03 / ЛИЧНЫЙ СЕЗОН'),
          const SizedBox(height: 16),
          Text(
            'Большие планы.\nТвои старты.',
            style: t.textTheme.headlineLarge,
          ),
          const SizedBox(height: 24),
          CutPanel(
            color: t.colorScheme.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Metric(
                        '${entries.length}'.padLeft(2, '0'),
                        'стартов в плане',
                      ),
                    ),
                    Expanded(
                      child: Metric(km.toStringAsFixed(1), 'км запланировано'),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(),
                const SizedBox(height: 14),
                const Text(
                  'Выбери дистанцию, задай темп и собирай свой сезон. Это планы, а не выполненные тренировки.',
                ),
              ],
            ),
          ),
          const SectionHeading('01', 'Сохранённые старты'),
          if (entries.isEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Text(
                'Твой сезон начинается с одного забега. Найди его в календаре.',
              ),
            ),
            FilledButton(
              onPressed: () => context.go('/races'),
              child: const Text('Выбрать забег'),
            ),
          ],
          for (final entry in entries)
            Dismissible(
              key: ValueKey(entry.id),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) => removeFromPlan(context, entry),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(24),
                color: t.colorScheme.errorContainer,
                child: Icon(
                  Icons.delete_outline,
                  color: t.colorScheme.onErrorContainer,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RaceCard(
                    race: catalog.byId(entry.raceId)!,
                    reminder: entry.distance == null
                        ? 'Выбери дистанцию'
                        : '${entry.distance} км · ${entry.pace} мин/км',
                    onTap: () => context.push('/races/${entry.raceId}'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () => context.push(
                            '/races/${entry.raceId}/participate',
                          ),
                          icon: const Icon(Icons.tune, size: 18),
                          label: const Text('Настроить старт'),
                        ),
                      ),
                      IconButton(
                        key: Key('remove-plan-${entry.raceId}'),
                        tooltip: 'Убрать из плана',
                        onPressed: model.isSaving
                            ? null
                            : () => removeFromPlan(context, entry),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
