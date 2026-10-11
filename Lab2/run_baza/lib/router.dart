import 'package:go_router/go_router.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/race_index_screen.dart';
import 'screens/race_details_screen.dart';
import 'screens/distance_screen.dart';
import 'screens/transfers_index_screen.dart';
import 'screens/transfer_screen.dart';
import 'screens/my_plan_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/not_found_screen.dart';

GoRouter createRouter({String initialLocation = '/login'}) => GoRouter(
  initialLocation: initialLocation,
  errorBuilder: (context, state) => const NotFoundScreen(),
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/races',
      builder: (context, state) => const RaceIndexScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) =>
              RaceDetailsScreen(id: state.pathParameters['id']!),
          routes: [
            GoRoute(
              path: 'distance/:km',
              builder: (context, state) => DistanceScreen(
                id: state.pathParameters['id']!,
                distance: double.tryParse(state.pathParameters['km']!) ?? -1,
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/transfers',
      builder: (context, state) => const TransfersIndexScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) =>
              TransferScreen(id: state.pathParameters['id']!),
        ),
      ],
    ),
    GoRoute(path: '/plan', builder: (context, state) => const MyPlanScreen()),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
