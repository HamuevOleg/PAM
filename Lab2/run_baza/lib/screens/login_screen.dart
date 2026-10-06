import 'package:flutter/material.dart';

import '../widgets/design.dart';
import '../widgets/event_glyph.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final s = t.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Вход')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Eyebrow('RUNBAZA / ТВОЯ ТОЧКА СБОРА'),
            const SizedBox(height: 20),
            CutPanel(
              color: s.surfaceContainerHighest,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Твой темп.\nТвои люди.',
                    style: t.textTheme.headlineLarge,
                  ),
                  const EventGlyph(kind: 'course', height: 138),
                  const Eyebrow('УВИДИМСЯ НА СТАРТЕ'),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('С возвращением', style: t.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Сохраняй забеги и планируй поездки вместе.',
              style: t.textTheme.bodyMedium?.copyWith(
                color: s.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            const TextField(
              keyboardType: TextInputType.emailAddress,
              autofillHints: [AutofillHints.email],
              decoration: InputDecoration(
                labelText: 'E-mail',
                hintText: 'runner@example.com',
                prefixIcon: Icon(Icons.alternate_email),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Пароль',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.maybePop(context),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('Войти'), Icon(Icons.arrow_forward, size: 20)],
              ),
            ),
            const SizedBox(height: 10),
            TextButton(onPressed: () {}, child: const Text('Создать аккаунт')),
          ],
        ),
      ),
    );
  }
}
