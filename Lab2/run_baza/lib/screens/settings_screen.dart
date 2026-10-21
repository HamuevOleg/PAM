import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/mock_repositories.dart';
import '../data/runner_profile.dart';
import '../models/profile_model.dart';
import '../models/collection_model.dart';
import '../models/plan_model.dart';
import '../models/race_catalog.dart';
import '../widgets/design.dart';
import '../widgets/data_status.dart';
import '../widgets/runner_avatar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _simulateError = false;
  bool _initialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _simulateError = context.read<MockRaceRepository>().simulateError;
      _initialized = true;
    }
  }

  Future<void> _savePreference(RunnerProfile profile) async {
    final error = await context.read<ProfileModel>().save(profile);
    if (!mounted || error == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Выйти из профиля?'),
        content: const Text(
          'Ты сможешь войти снова. Незавершённые изменения формы не сохранятся.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Остаться'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    context.read<ProfileModel>().endSession();
    context.go('/login');
  }

  Widget _failureControl() => SwitchListTile.adaptive(
    key: const Key('simulate-error'),
    contentPadding: EdgeInsets.zero,
    title: const Text('Симулировать сбой сети'),
    subtitle: const Text('Проверка загрузки и сохранения'),
    value: _simulateError,
    onChanged: (value) {
      setState(() => _simulateError = value);
      context.read<MockRaceRepository>().simulateError = value;
    },
  );

  @override
  Widget build(BuildContext context) {
    final profileModel = context.watch<ProfileModel>();
    final plan = context.watch<PlanModel>();
    final catalog = context.watch<RaceCatalog>();
    final models = <LoadableState>[profileModel, plan, catalog];
    final loading = models.any((m) => m.isLoading);
    final errors = models.map((m) => m.error).whereType<String>();
    if (loading || errors.isNotEmpty || profileModel.profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Профиль')),
        body: Column(
          children: [
            Expanded(
              child: loading
                  ? const LoadingView()
                  : ErrorView(
                      message: errors.isEmpty
                          ? 'Профиль не найден.'
                          : errors.first,
                      onRetry: () {
                        context.read<ProfileModel>().load();
                        context.read<PlanModel>().load();
                        context.read<RaceCatalog>().load();
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: _failureControl(),
            ),
          ],
        ),
      );
    }
    final profile = profileModel.profile!;
    final entries = plan.records
        .where((e) => catalog.byId(e.raceId) != null)
        .toList();
    final kilometers = entries.fold<double>(
      0,
      (sum, e) => sum + (e.distance ?? 0),
    );
    final countries = entries
        .map((e) => catalog.byId(e.raceId)!.country)
        .toSet()
        .length;
    final progress = (entries.length / profile.seasonGoal).clamp(0.0, 1.0);
    final t = Theme.of(context);
    final s = t.colorScheme;
    final appearance = profile.appearance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            key: const Key('profile-edit'),
            tooltip: 'Редактировать профиль',
            onPressed: () => context.push('/profile/edit'),
            icon: const Icon(Icons.edit_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
        children: [
          const Eyebrow('04 / БЕГОВОЙ ПАСПОРТ'),
          const SizedBox(height: 18),
          Semantics(
            container: true,
            label: 'Беговой паспорт',
            child: CutPanel(
              color: const Color(0xFF252820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'RUNBAZA  /  RUNNER',
                          style: TextStyle(
                            color: Color(0xFFE9F29B),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.6,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.fingerprint,
                        color: Colors.white.withValues(alpha: .5),
                        size: 27,
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RunnerAvatar(name: profile.name, variant: profile.avatar),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name,
                              key: const Key('profile-display-name'),
                              style: t.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              profile.city,
                              style: const TextStyle(color: Color(0xFFCCD0BE)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    profile.bio.isEmpty
                        ? 'У каждого бегуна своя история.'
                        : profile.bio,
                    style: const TextStyle(
                      color: Color(0xFFCCD0BE),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Divider(color: Colors.white.withValues(alpha: .18)),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 28,
                    runSpacing: 14,
                    children: [
                      _PassportValue(profile.pace, 'МИН / КМ'),
                      _PassportValue(
                        '${profile.preferredDistance}',
                        'ЛЮБИМАЯ ДИСТАНЦИЯ, КМ',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    profile.email,
                    style: const TextStyle(
                      color: Color(0xFFCCD0BE),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => context.push('/profile/edit'),
            icon: const Icon(Icons.tune, size: 18),
            label: const Text('Настроить мой профиль'),
          ),
          const SectionHeading('01', 'Мой сезон'),
          CutPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        '${entries.length} / ${profile.seasonGoal}',
                        key: const Key('profile-plan-count'),
                        style: t.textTheme.displaySmall,
                      ),
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text(
                          'стартов в плане\nиз цели на сезон',
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: s.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Metric(
                        kilometers.toStringAsFixed(1),
                        'км запланировано',
                      ),
                    ),
                    Expanded(child: Metric('$countries', 'стран в плане')),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Это твой план, не статистика завершённых тренировок.',
                  style: t.textTheme.bodySmall?.copyWith(
                    color: s.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => context.go('/plan'),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Открыть мой план'),
                ),
              ],
            ),
          ),
          const SectionHeading('02', 'Скоро на старте'),
          if (entries.isEmpty)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_available),
              title: const Text('Сезон ещё не спланирован'),
              subtitle: const Text('Выбери первый забег'),
              onTap: () => context.go('/races'),
            ),
          for (final entry in entries.take(2))
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 42,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: s.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    catalog.byId(entry.raceId)!.date.split('.').first,
                    style: t.textTheme.titleLarge?.copyWith(
                      color: s.onPrimaryContainer,
                    ),
                  ),
                ),
                title: Text(
                  catalog.byId(entry.raceId)!.title,
                  style: t.textTheme.titleMedium,
                ),
                subtitle: Text(
                  '${catalog.byId(entry.raceId)!.date} · ${entry.distance ?? "?"} км',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/races/${entry.raceId}'),
              ),
            ),
          const SectionHeading('03', 'Под твой ритм'),
          const Text('Оформление'),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<AppAppearance>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: AppAppearance.system, label: Text('Авто')),
                ButtonSegment(
                  value: AppAppearance.light,
                  label: Text('Светлая'),
                ),
                ButtonSegment(value: AppAppearance.dark, label: Text('Тёмная')),
              ],
              selected: {appearance},
              onSelectionChanged: profileModel.isSaving
                  ? null
                  : (values) => _savePreference(
                      profile.copyWith(appearance: values.single),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Открытый план'),
            subtitle: const Text('Видимость для новых стартов'),
            value: profile.publicPlan,
            onChanged: profileModel.isSaving
                ? null
                : (value) =>
                      _savePreference(profile.copyWith(publicPlan: value)),
          ),
          const Divider(),
          const SizedBox(height: 8),
          ExpansionTile(
            key: const Key('diagnostics'),
            tilePadding: EdgeInsets.zero,
            title: const Text('Диагностика'),
            leading: const Icon(Icons.tune_outlined),
            children: [_failureControl()],
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            key: const Key('logout'),
            onPressed: _logout,
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Выйти из профиля'),
          ),
          const SizedBox(height: 20),
          Text(
            'RUNBAZA / НА ОДНОЙ ВОЛНЕ',
            textAlign: TextAlign.center,
            style: t.textTheme.labelSmall?.copyWith(color: s.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _PassportValue extends StatelessWidget {
  final String value, label;
  const _PassportValue(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        label,
        style: const TextStyle(
          color: Color(0xFFCCD0BE),
          fontSize: 9,
          letterSpacing: .8,
        ),
      ),
    ],
  );
}
