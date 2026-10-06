import 'package:flutter/material.dart';

import '../widgets/design.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final s = t.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const Eyebrow('04 / ТВОЙ ПРОФИЛЬ'),
          const SizedBox(height: 18),
          Text('Бег начинается\nс тебя.', style: t.textTheme.headlineLarge),
          const SizedBox(height: 26),
          CutPanel(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 29,
                  backgroundColor: s.primary,
                  foregroundColor: s.onPrimary,
                  child: const Text(
                    'HO',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hamuev Oleg', style: t.textTheme.titleLarge),
                      const SizedBox(height: 5),
                      const Text('Chișinău · начинающий сезон'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SectionHeading('01', 'Предпочтения'),
          const DropdownMenu<String>(
            initialSelection: 'Chișinău',
            expandedInsets: EdgeInsets.zero,
            label: Text('Домашний город'),
            dropdownMenuEntries: [
              DropdownMenuEntry(value: 'Chișinău', label: 'Chișinău'),
              DropdownMenuEntry(value: 'Iași', label: 'Iași'),
              DropdownMenuEntry(value: 'București', label: 'București'),
            ],
          ),
          const SizedBox(height: 18),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.brightness_auto_outlined),
            title: const Text('Оформление'),
            subtitle: const Text('Светлая и тёмная темы — как в iOS'),
            trailing: Text(
              t.brightness == Brightness.dark ? 'Тёмная' : 'Светлая',
              style: t.textTheme.bodySmall,
            ),
          ),
          const SectionHeading('02', 'Не пропусти старт'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Уведомления'),
            subtitle: const Text('Перед стартом и закрытием регистрации'),
            value: true,
            onChanged: (_) {},
          ),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Напоминания о поездке'),
            subtitle: const Text('За день до выезда'),
            value: true,
            onChanged: (_) {},
          ),
          const SectionHeading('03', 'Аккаунт'),
          OutlinedButton.icon(
            onPressed: () => openScreen(context, const LoginScreen()),
            icon: const Icon(Icons.login),
            label: const Text('Экран входа'),
          ),
          const SizedBox(height: 22),
          Text(
            'RunBaza · версия 1.0',
            style: t.textTheme.bodySmall?.copyWith(color: s.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
