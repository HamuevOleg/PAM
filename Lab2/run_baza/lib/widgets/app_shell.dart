import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/plan_model.dart';

/// Each branch owns its navigator, scroll position and local form state.
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const AppShell({super.key, required this.navigationShell});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: navigationShell.goBranch,
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          label: 'Главная',
        ),
        const NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          label: 'Забеги',
        ),
        const NavigationDestination(
          icon: Icon(Icons.directions_car_outlined),
          label: 'Попутки',
        ),
        NavigationDestination(
          icon: Consumer<PlanModel>(
            builder: (context, plan, child) => Badge(
              key: const Key('plan-badge'),
              isLabelVisible: plan.count > 0,
              label: Text('${plan.count}'),
              child: child!,
            ),
            child: const Icon(Icons.bookmark_outline),
          ),
          label: 'Мой план',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Профиль',
        ),
      ],
    ),
  );
}
