import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/plan_entry.dart';
import '../models/plan_model.dart';

Future<bool> removeFromPlan(BuildContext context, PlanEntry entry) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Убрать забег из плана?'),
      content: const Text(
        'Дистанция и настройки этого старта будут удалены. Забег останется в календаре.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Оставить'),
        ),
        FilledButton(
          key: const Key('confirm-remove-plan'),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Убрать'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return false;
  final error = await context.read<PlanModel>().remove(entry.id);
  if (!context.mounted) return false;
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(error ?? 'Забег убран из плана')));
  return error == null;
}
