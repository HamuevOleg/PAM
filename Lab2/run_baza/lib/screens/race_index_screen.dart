import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/race.dart';
import '../models/race_catalog.dart';
import '../widgets/data_status.dart';
import '../widgets/design.dart';
import '../widgets/race_card.dart';

class RaceIndexScreen extends StatefulWidget {
  const RaceIndexScreen({super.key});
  @override
  State<RaceIndexScreen> createState() => _RaceIndexScreenState();
}

class _RaceIndexScreenState extends State<RaceIndexScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounce;
  bool _initialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _search.text = context.read<RaceCatalog>().search;
      _initialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 240) {
        final catalog = context.read<RaceCatalog>();
        if (catalog.moreError == null) catalog.loadMore();
      }
    });
  }

  void _submit(String query) {
    _debounce?.cancel();
    context.read<RaceCatalog>().load(search: query.trim());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<RaceCatalog>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Календарь забегов'),
        actions: [
          IconButton(
            key: const Key('reload-races'),
            tooltip: 'Обновить',
            onPressed: () => catalog.load(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        controller: _scroll,
        key: const PageStorageKey('race-list'),
        padding: const EdgeInsets.all(22),
        children: [
          const Eyebrow('01 / НАЙТИ СОБЫТИЕ'),
          const SizedBox(height: 16),
          Text(
            'У каждого старта\nсвой характер.',
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(height: 24),
          TextField(
            key: const Key('race-search'),
            controller: _search,
            textInputAction: TextInputAction.search,
            onSubmitted: _submit,
            onChanged: (value) {
              setState(() {});
              _debounce?.cancel();
              _debounce = Timer(
                const Duration(milliseconds: 400),
                () => _submit(value),
              );
            },
            decoration: InputDecoration(
              hintText: 'Забег, город или дистанция',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Очистить поиск',
                      onPressed: () {
                        setState(_search.clear);
                        _submit('');
                      },
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
                selected: catalog.country.isEmpty,
                onSelected: (_) => catalog.load(country: ''),
              ),
              for (final c in RaceCountry.values)
                ChoiceChip(
                  label: Text(c.label),
                  selected: catalog.country == c.name,
                  onSelected: (_) => catalog.load(country: c.name),
                ),
            ],
          ),
          if (catalog.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: LoadingView(),
            )
          else if (catalog.error != null)
            ErrorView(message: catalog.error!, onRetry: () => catalog.load())
          else ...[
            SectionHeading(catalog.count.toString().padLeft(2, '0'), 'События'),
            if (catalog.records.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'Ничего не найдено. Попробуй другой город или название.',
                ),
              ),
            for (final race in catalog.records)
              RaceCard(
                key: ValueKey(race.id),
                race: race,
                onTap: () => context.push('/races/${race.id}'),
              ),
            if (catalog.hasMore)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    if (catalog.moreError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          catalog.moreError!,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (catalog.loadingMore)
                      const CircularProgressIndicator(key: Key('loading-more'))
                    else
                      OutlinedButton.icon(
                        key: const Key('load-more'),
                        onPressed: () => catalog.loadMore(),
                        icon: const Icon(Icons.expand_more),
                        label: Text(
                          catalog.moreError == null
                              ? 'Показать ещё'
                              : 'Повторить загрузку',
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
