import 'package:provider/provider.dart';

import '../data/session_controller.dart';
import '../data/result.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/design.dart';
import '../forms/validators.dart';
import '../widgets/event_glyph.dart';

class LoginScreen extends StatefulWidget {
  final ValueChanged<String>? onSignedIn;
  const LoginScreen({super.key, this.onSignedIn});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidden = true;
  bool _signingIn = false;

  Future<void> _signIn() async {
    if (_signingIn || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final email = _email.text.trim().toLowerCase();
    setState(() => _signingIn = true);
    final session = context.read<SessionController>();
    final results = await Future.wait([
      session.auth.login(email, _password.text),
      Future<void>.delayed(const Duration(seconds: 3)),
    ]);
    if (!mounted) return;
    final result = results.first as Result<void>;
    if (result case Err(:final msg)) {
      setState(() => _signingIn = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }
    session.acceptLogin();
    if (!mounted) return;
    widget.onSignedIn?.call(email);
    context.go('/home');
  }

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
              // Keep every FormField mounted so validate checks off-screen fields.
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    enabled: !_signingIn,
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
                    enabled: !_signingIn,
                    validator: Validators.password,
                    obscureText: _hidden,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: _hidden ? 'Показать пароль' : 'Скрыть пароль',
                        onPressed: _signingIn
                            ? null
                            : () => setState(() => _hidden = !_hidden),
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
                    onPressed: _signingIn ? null : _signIn,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_signingIn ? 'Входим…' : 'Войти'),
                        if (_signingIn)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              key: Key('login-loading'),
                              strokeWidth: 2,
                              semanticsLabel: 'Выполняется вход',
                            ),
                          )
                        else
                          const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    key: const Key('login-register'),
                    onPressed: _signingIn
                        ? null
                        : () => context.push('/register'),
                    child: const Text('Создать профиль'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
