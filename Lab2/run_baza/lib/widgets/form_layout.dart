import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'design.dart';

class FormLayout extends StatelessWidget {
  final String title, eyebrow, description;
  final GlobalKey<FormState> formKey;
  final List<Widget> fields;
  final VoidCallback onSubmit;
  final bool isSaving;
  final Key submitKey;
  const FormLayout({
    super.key,
    required this.title,
    required this.eyebrow,
    required this.description,
    required this.formKey,
    required this.fields,
    required this.onSubmit,
    this.isSaving = false,
    this.submitKey = const Key('submit-form'),
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.all(22),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          // Keep every FormField mounted so validate checks off-screen fields.
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Eyebrow(eyebrow),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 12),
              Text(description),
              const SizedBox(height: 26),
              for (final field in fields)
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: field,
                ),
              FilledButton.icon(
                key: submitKey,
                onPressed: isSaving ? null : onSubmit,
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(isSaving ? 'Сохраняем...' : 'Подтвердить'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
    ),
  );
}

void finishForm(BuildContext context, String message, {String? destination}) {
  FocusScope.of(context).unfocus();
  final messenger = ScaffoldMessenger.of(context);
  if (destination != null) {
    context.go(destination);
  } else if (context.canPop()) {
    context.pop();
  } else {
    context.go('/home');
  }
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(SnackBar(content: Text(message)));
}
