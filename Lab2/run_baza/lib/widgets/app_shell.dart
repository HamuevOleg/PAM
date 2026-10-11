import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          label: 'Главная',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          label: 'Забеги',
        ),
        NavigationDestination(
          icon: Icon(Icons.directions_car_outlined),
          label: 'Попутки',
        ),
        NavigationDestination(
          icon: Icon(Icons.bookmark_outline),
          label: 'Мой план',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Профиль',
        ),
      ],
    ),
  );
}
