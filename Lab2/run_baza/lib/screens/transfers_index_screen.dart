import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';

import '../models/race_catalog.dart';
import '../widgets/data_status.dart';
import '../widgets/design.dart';
import '../widgets/race_card.dart';

class TransfersIndexScreen extends StatelessWidget {
  const TransfersIndexScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<RaceCatalog>();
    final state = dataScreenState(context, 'Попутки', [catalog]);
    if (state != null) return state;
    final races = catalog.records;
    return Scaffold(
      appBar: AppBar(title: const Text('Попутки')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const Eyebrow('02 / ОДНА ДОРОГА — ОБЩИЙ СТАРТ'),
          const SizedBox(height: 16),
          Text('С кем едем?', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 12),
          const Text(
            'Выбери забег, чтобы найти попутчиков или предложить поездку.',
          ),
          const SizedBox(height: 24),
          for (final race in races)
            RaceCard(
              race: race,
              onTap: () => context.push('/transfers/${race.id}'),
            ),
        ],
      ),
    );
  }
}
