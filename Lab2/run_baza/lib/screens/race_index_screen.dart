import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_data.dart';
import '../widgets/design.dart';
import '../widgets/race_card.dart';

class RaceIndexScreen extends StatefulWidget {
  const RaceIndexScreen({super.key});
  @override
  State<RaceIndexScreen> createState() => _RaceIndexScreenState();
}

class _RaceIndexScreenState extends State<RaceIndexScreen> {
  final _search = TextEditingController();
  RaceCountry? _country;
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final visible = races
        .where(
          (r) =>
              (_country == null || r.country == _country) &&
              '${r.title} ${r.city} ${r.distanceLabel}'.toLowerCase().contains(
                query,
              ),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Календарь забегов')),
      body: ListView(
        key: const PageStorageKey('race-list'),
        padding: const EdgeInsets.all(22),
        children: [
          const Eyebrow('01 / НАЙТИ СОБЫТИЕ'),
          const SizedBox(height: 16),
          Text(
            'У каждого старта\nсвой характер.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 24),
          TextField(
            key: const Key('race-search'),
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Забег, город или дистанция',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Очистить поиск',
                      onPressed: () => setState(_search.clear),
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Все'),
                selected: _country == null,
                onSelected: (_) => setState(() => _country = null),
              ),
              for (final c in RaceCountry.values)
                ChoiceChip(
                  label: Text(c.label),
                  selected: _country == c,
                  onSelected: (_) => setState(() => _country = c),
                ),
            ],
          ),
          SectionHeading(visible.length.toString().padLeft(2, '0'), 'События'),
          if (visible.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'Ничего не найдено. Попробуй другой город или название.',
              ),
            ),
          for (final race in visible)
            RaceCard(
              key: ValueKey(race.id),
              race: race,
              onTap: () => context.push('/races/${race.id}'),
            ),
        ],
      ),
    );
  }
}
