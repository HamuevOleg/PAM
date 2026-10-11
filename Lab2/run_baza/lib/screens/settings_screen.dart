import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../forms/validators.dart';
import '../widgets/design.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController(text: 'Hamuev Oleg');
  final _pace = TextEditingController(text: '6:00');
  String? _city = 'Chișinău';
  @override
  void dispose() {
    _name.dispose();
    _pace.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Выйти из профиля?'),
        content: const Text(
          'Несохранённые поля будут сброшены. Можно будет войти снова.',
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
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const Eyebrow('04 / ТВОЙ БЕГОВОЙ ПАСПОРТ'),
            const SizedBox(height: 18),
            Text(
              'Каждый старт\nначинается с тебя.',
              style: t.textTheme.headlineLarge,
            ),
            const SizedBox(height: 24),
            CutPanel(
              color: t.colorScheme.surfaceContainerHighest,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Eyebrow('RUNNER / CR232'),
                      Icon(Icons.fingerprint, size: 36),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text('Hamuev Oleg', style: t.textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  const Text('Chișinău, Молдова'),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(child: Metric('06', 'стартов в плане')),
                      Expanded(child: Metric('—', 'подтверждённых финишей')),
                    ],
                  ),
                ],
              ),
            ),
            const SectionHeading('01', 'Мои данные'),
            TextFormField(
              key: const Key('profile-name'),
              controller: _name,
              decoration: const InputDecoration(labelText: 'Имя'),
              validator: Validators.name,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              key: const Key('profile-city'),
              initialValue: _city,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Домашний город'),
              items: [
                'Chișinău',
                'Bălți',
                'Iași',
                'București',
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _city = v),
              validator: (v) => v == null ? 'Выберите город' : null,
            ),
            const SizedBox(height: 18),
            TextFormField(
              key: const Key('profile-pace'),
              controller: _pace,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                labelText: 'Комфортный темп, мин/км',
                hintText: '6:00',
              ),
              validator: Validators.pace,
            ),
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('profile-submit'),
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                FocusScope.of(context).unfocus();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Данные профиля проверены')),
                );
              },
              child: const Text('Проверить данные'),
            ),
            const SectionHeading('02', 'Аккаунт'),
            OutlinedButton.icon(
              key: const Key('logout'),
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Выйти из профиля'),
            ),
            const SizedBox(height: 24),
            Text('RunBaza · На одной волне', style: t.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
