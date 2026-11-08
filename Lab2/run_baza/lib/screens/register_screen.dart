import 'package:provider/provider.dart';

import '../data/session_controller.dart';
import '../data/result.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/runner_identity.dart';
import '../forms/validators.dart';
import '../widgets/design.dart';

class RegisterScreen extends StatefulWidget {
  final ValueChanged<RunnerIdentity>? onRegistered;
  const RegisterScreen({super.key, this.onRegistered});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _busy = false;
  bool _hidePassword = true;
  bool _hideConfirmation = true;

  @override
  void dispose() {
    for (final controller in [_name, _email, _password, _confirmation]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    final result = await context.read<SessionController>().register(
      _email.text,
      _password.text,
      _name.text,
    );
    if (!mounted) return;
    if (result case Err(:final msg)) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }
    widget.onRegistered?.call(
      RunnerIdentity(
        name: _name.text.trim(),
        email: _email.text.trim().toLowerCase(),
      ),
    );
    _password.clear();
    _confirmation.clear();
    context.go('/home');
  }

  void _backToLogin() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация'),
        leading: IconButton(
          key: const Key('register-back'),
          tooltip: 'Вернуться ко входу',
          onPressed: _busy ? null : _backToLogin,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.all(24),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                // All fields stay mounted, including when the keyboard is open.
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Eyebrow('RUNBAZA / ПЕРВЫЙ ШАГ'),
                    const SizedBox(height: 18),
                    CutPanel(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Eyebrow('ТВОЙ БЕГОВОЙ ПАСПОРТ'),
                              ),
                              Icon(
                                Icons.fingerprint,
                                size: 36,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Начни свою\nисторию бега.',
                            style: theme.textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Забеги, попутчики и планы — в одном месте.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    TextFormField(
                      key: const Key('register-name'),
                      controller: _name,
                      enabled: !_busy,
                      validator: Validators.name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      decoration: const InputDecoration(
                        labelText: 'Имя и фамилия',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('register-email'),
                      controller: _email,
                      enabled: !_busy,
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        hintText: 'runner@example.com',
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('register-password'),
                      controller: _password,
                      enabled: !_busy,
                      validator: Validators.registrationPassword,
                      obscureText: _hidePassword,
                      enableSuggestions: false,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: 'Пароль',
                        helperText: 'Не менее 8 символов',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          key: const Key('register-password-visibility'),
                          tooltip: _hidePassword
                              ? 'Показать пароль'
                              : 'Скрыть пароль',
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('register-confirmation'),
                      controller: _confirmation,
                      enabled: !_busy,
                      validator: (value) =>
                          Validators.confirmPassword(value, _password.text),
                      obscureText: _hideConfirmation,
                      enableSuggestions: false,
                      autocorrect: false,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'Повторите пароль',
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                        suffixIcon: IconButton(
                          key: const Key('register-confirmation-visibility'),
                          tooltip: _hideConfirmation
                              ? 'Показать повтор пароля'
                              : 'Скрыть повтор пароля',
                          onPressed: () => setState(
                            () => _hideConfirmation = !_hideConfirmation,
                          ),
                          icon: Icon(
                            _hideConfirmation
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const Key('register-submit'),
                      onPressed: _busy ? null : _submit,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _busy ? 'Создаём профиль…' : 'Создать профиль',
                            ),
                          ),
                          if (_busy)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      key: const Key('register-login'),
                      onPressed: _busy ? null : _backToLogin,
                      child: const Text('Уже есть профиль? Войти'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
