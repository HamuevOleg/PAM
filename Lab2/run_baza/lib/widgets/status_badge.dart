import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});
  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final cancelled = status == 'Cancelled';
    final warning = status == 'Last call';
    final inactive = status == 'TBA' || status == 'Departed';
    final fg = cancelled
        ? s.error
        : warning
        ? s.tertiary
        : inactive
        ? s.onSurfaceVariant
        : s.primary;
    final label = switch (status) {
      'Boarding' => 'Регистрация открыта',
      'Last call' => 'Последние места',
      'On time' => 'Старт подтверждён',
      'TBA' => 'Скоро регистрация',
      'Cancelled' => 'Отменён',
      'Departed' => 'Завершён',
      _ => status,
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          cancelled ? Icons.close : Icons.circle,
          size: cancelled ? 14 : 6,
          color: fg,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ),
      ],
    );
  }
}
