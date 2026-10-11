import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/design.dart';
import '../forms/validators.dart';
import '../widgets/event_glyph.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidden = true;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final s = t.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Вход')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
              TextFormField(
                key: const Key('login-email'),
                controller: _email,
                validator: Validators.email,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                autofillHints: [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  hintText: 'runner@example.com',
                  prefixIcon: Icon(Icons.alternate_email),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('login-password'),
                controller: _password,
                validator: Validators.password,
                obscureText: _hidden,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    tooltip: _hidden ? 'Показать пароль' : 'Скрыть пароль',
                    onPressed: () => setState(() => _hidden = !_hidden),
                    icon: Icon(
                      _hidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                key: const Key('login-submit'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    FocusScope.of(context).unfocus();
                    context.go('/home');
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Войти'),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
