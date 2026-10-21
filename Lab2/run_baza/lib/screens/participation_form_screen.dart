import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import '../data/plan_entry.dart';
import '../models/race_catalog.dart';
import '../models/plan_model.dart';
import '../widgets/data_status.dart';
import '../forms/validators.dart';
import '../widgets/form_layout.dart';
import 'not_found_screen.dart';

class ParticipationFormScreen extends StatefulWidget {
  final String id;
  const ParticipationFormScreen({super.key, required this.id});
  @override
  State<ParticipationFormScreen> createState() =>
      _ParticipationFormScreenState();
}

class _ParticipationFormScreenState extends State<ParticipationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pace = TextEditingController();
  double? _distance;
  String? _visibility;
  bool _initialized = false;
  @override
  void dispose() {
    _pace.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<RaceCatalog>();
    final plan = context.watch<PlanModel>();
    final state = dataScreenState(context, 'Мой старт', [catalog, plan]);
    if (state != null) return state;
    final race = catalog.byId(widget.id);
    if (race == null) return const NotFoundScreen();
    if (!_initialized) {
      final existing = plan.forRace(widget.id);
      if (existing != null) {
        _distance = existing.distance;
        _pace.text = existing.pace;
        _visibility = existing.visibility;
      }
      _initialized = true;
    }
    return FormLayout(
      isSaving: plan.isSaving,
      title: 'Мой старт',
      eyebrow: '${race.code} / БЕЖИМ ВМЕСТЕ',
      description: '${race.title}\nВыбери дистанцию и свой комфортный темп.',
      formKey: _formKey,
      fields: [
        DropdownButtonFormField<double>(
          key: const Key('run-distance'),
          initialValue: _distance,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Дистанция'),
          items: race.distances
              .map((d) => DropdownMenuItem(value: d, child: Text('$d км')))
              .toList(),
          onChanged: (v) => setState(() => _distance = v),
          validator: (v) => v == null ? 'Выберите дистанцию' : null,
        ),
        TextFormField(
          key: const Key('run-pace'),
          controller: _pace,
          keyboardType: TextInputType.datetime,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
            LengthLimitingTextInputFormatter(5),
          ],
          decoration: const InputDecoration(
            labelText: 'Темп, мин/км',
            hintText: '6:00',
            helperText: 'Время на один километр',
          ),
          validator: Validators.pace,
        ),
        DropdownButtonFormField<String>(
          key: const Key('run-visibility'),
          initialValue: _visibility,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Кому виден мой план'),
          items: const [
            DropdownMenuItem(value: 'private', child: Text('Только мне')),
            DropdownMenuItem(
              value: 'runners',
              child: Text('Участникам забега'),
            ),
          ],
          onChanged: (v) => setState(() => _visibility = v),
          validator: (v) => v == null ? 'Выберите видимость' : null,
        ),
      ],
      onSubmit: () async {
        if (!_formKey.currentState!.validate()) return;
        final model = context.read<PlanModel>();
        final existing = model.forRace(widget.id);
        final draft = PlanEntry(
          widget.id,
          existing?.reminderDays ?? 2,
          distance: _distance!,
          pace: _pace.text.trim(),
          visibility: _visibility!,
        );
        final error = await model.saveForRace(draft);
        if (!mounted) return;
        if (error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error)));
          return;
        }
        finishForm(context, 'Старт сохранён в плане');
      },
    );
  }
}
