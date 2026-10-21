import 'package:flutter/material.dart';

import '../models/collection_model.dart';

Widget? dataScreenState(
  BuildContext context,
  String title,
  List<LoadableState> models,
) {
  final loading = models.any((model) => model.isLoading);
  final errors = models.map((model) => model.error).whereType<String>();
  if (!loading && errors.isEmpty) return null;
  return Scaffold(
    appBar: AppBar(title: Text(title)),
    body: loading
        ? const LoadingView()
        : ErrorView(
            message: errors.first,
            onRetry: () {
              for (final model in models) {
                model.load();
              }
            },
          ),
  );
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 24),
          Text(
            'Собираем твой сезон',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Забеги, планы и люди рядом.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorView({super.key, required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: t.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                size: 38,
                color: t.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 26),
            Text('Небольшая пауза', style: t.textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              key: const Key('retry'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}
