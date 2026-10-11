import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/mock_data.dart';
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
  @override
  void dispose() {
    _pace.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final race = findRace(widget.id);
    if (race == null) return const NotFoundScreen();
    return FormLayout(
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
      onSubmit: () {
        if (!_formKey.currentState!.validate()) return;
        finishForm(context, 'Параметры старта проверены');
      },
    );
  }
}
