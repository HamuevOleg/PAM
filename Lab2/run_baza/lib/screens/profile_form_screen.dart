import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/profile_model.dart';
import '../forms/validators.dart';
import '../widgets/data_status.dart';
import '../widgets/form_layout.dart';
import '../widgets/runner_avatar.dart';

class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key});
  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _bio = TextEditingController();
  final _pace = TextEditingController();
  final _goal = TextEditingController();
  bool _initialized = false;
  String? _city;
  double? _distance;
  int _avatar = 0;
  @override
  void dispose() {
    for (final controller in [_name, _email, _bio, _pace, _goal]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ProfileModel>();
    final state = dataScreenState(context, 'Мои данные', [model]);
    if (state != null) return state;
    final profile = model.profile;
    if (profile == null) {
      return const Scaffold(body: Center(child: Text('Профиль не найден.')));
    }
    if (!_initialized) {
      _name.text = profile.name;
      _email.text = profile.email;
      _bio.text = profile.bio;
      _pace.text = profile.pace;
      _goal.text = '${profile.seasonGoal}';
      _city = profile.city;
      _distance = profile.preferredDistance;
      _avatar = profile.avatar;
      _initialized = true;
    }
    return FormLayout(
      title: 'Мои данные',
      eyebrow: 'RUNNER / ЛИЧНЫЕ НАСТРОЙКИ',
      description: 'Имя, темп и планы на сезон. Сделай профиль своим.',
      formKey: _formKey,
      isSaving: model.isSaving,
      submitKey: const Key('profile-submit'),
      fields: [
        Wrap(
          spacing: 14,
          runSpacing: 12,
          children: [
            for (var i = 0; i < 4; i++)
              Semantics(
                selected: _avatar == i,
                button: true,
                label: 'Цвет аватара ${i + 1}',
                child: InkWell(
                  key: Key('avatar-$i'),
                  onTap: () => setState(() => _avatar = i),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        width: 2,
                        color: _avatar == i
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                      ),
                    ),
                    child: RunnerAvatar(name: _name.text, variant: i, size: 46),
                  ),
                ),
              ),
          ],
        ),
        TextFormField(
          key: const Key('profile-name'),
          controller: _name,
          decoration: const InputDecoration(labelText: 'Имя'),
          validator: Validators.name,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}),
        ),
        TextFormField(
          key: const Key('profile-email'),
          controller: _email,
          decoration: const InputDecoration(labelText: 'E-mail'),
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email,
        ),
        DropdownButtonFormField<String>(
          key: const Key('profile-city'),
          initialValue: _city,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Домашний город'),
          items: ['Chișinău', 'Bălți', 'Iași', 'București']
              .map((city) => DropdownMenuItem(value: city, child: Text(city)))
              .toList(),
          onChanged: (value) => setState(() => _city = value),
          validator: (value) => value == null ? 'Выберите город' : null,
        ),
        TextFormField(
          key: const Key('profile-bio'),
          controller: _bio,
          decoration: const InputDecoration(
            labelText: 'О себе',
            hintText: 'Что приводит тебя на старт?',
          ),
          maxLines: 3,
          maxLength: 160,
          textCapitalization: TextCapitalization.sentences,
        ),
        TextFormField(
          key: const Key('profile-pace'),
          controller: _pace,
          keyboardType: TextInputType.datetime,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
            LengthLimitingTextInputFormatter(5),
          ],
          decoration: const InputDecoration(
            labelText: 'Комфортный темп, мин/км',
            hintText: '6:00',
          ),
          validator: Validators.pace,
        ),
        DropdownButtonFormField<double>(
          key: const Key('profile-distance'),
          initialValue: _distance,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Любимая дистанция'),
          items: [3.0, 5.0, 10.0, 21.1, 42.2]
              .map((d) => DropdownMenuItem(value: d, child: Text('$d км')))
              .toList(),
          onChanged: (value) => setState(() => _distance = value),
          validator: (value) => value == null ? 'Выберите дистанцию' : null,
        ),
        TextFormField(
          key: const Key('profile-goal'),
          controller: _goal,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          decoration: const InputDecoration(
            labelText: 'Цель на сезон, стартов',
            helperText: 'От 1 до 52 забегов в плане',
          ),
          validator: (value) {
            final n = int.tryParse(value ?? '');
            return n == null || n < 1 || n > 52
                ? 'Укажите от 1 до 52 стартов'
                : null;
          },
        ),
      ],
      onSubmit: () async {
        if (!_formKey.currentState!.validate()) return;
        final draft = profile.copyWith(
          name: _name.text.trim(),
          email: _email.text.trim().toLowerCase(),
          city: _city!,
          pace: _pace.text.trim(),
          bio: _bio.text.trim(),
          preferredDistance: _distance!,
          seasonGoal: int.parse(_goal.text),
          avatar: _avatar,
        );
        final error = await context.read<ProfileModel>().save(draft);
        if (!context.mounted) return;
        if (error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error)));
          return;
        }
        finishForm(context, 'Профиль сохранён', destination: '/profile');
      },
    );
  }
}
