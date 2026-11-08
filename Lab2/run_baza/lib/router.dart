import 'package:go_router/go_router.dart';

import 'data/session_controller.dart';
import 'screens/profile_form_screen.dart';

import 'widgets/app_shell.dart';
import 'screens/register_screen.dart';

import 'screens/home_screen.dart';
import 'screens/trip_form_screen.dart';
import 'screens/participation_form_screen.dart';
import 'screens/login_screen.dart';
import 'screens/race_index_screen.dart';
import 'screens/race_details_screen.dart';
import 'screens/distance_screen.dart';
import 'screens/transfers_index_screen.dart';
import 'screens/transfer_screen.dart';
import 'screens/my_plan_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/not_found_screen.dart';

GoRouter createRouter({
  String initialLocation = '/login',
  SessionController? session,
}) {
  return GoRouter(
    initialLocation: session?.signedIn == true ? '/home' : initialLocation,
    refreshListenable: session,
    redirect: (context, state) {
      if (session == null) return null;
      final auth = state.uri.path == '/login' || state.uri.path == '/register';
      if (!session.signedIn && !auth) return '/login';
      if (session.signedIn && auth) return '/home';
      return null;
    },
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
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
                        path: 'participate',
                        builder: (context, state) => ParticipationFormScreen(
                          id: state.pathParameters['id']!,
                        ),
                      ),
                      GoRoute(
                        path: 'distance/:km',
                        builder: (context, state) => DistanceScreen(
                          id: state.pathParameters['id']!,
                          distance:
                              double.tryParse(state.pathParameters['km']!) ??
                              -1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transfers',
                builder: (context, state) => const TransfersIndexScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) =>
                        TransferScreen(id: state.pathParameters['id']!),
                    routes: [
                      GoRoute(
                        path: 'offer',
                        builder: (context, state) => TripFormScreen(
                          id: state.pathParameters['id']!,
                          driver: true,
                        ),
                      ),
                      GoRoute(
                        path: 'request',
                        builder: (context, state) => TripFormScreen(
                          id: state.pathParameters['id']!,
                          driver: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/plan',
                builder: (context, state) => const MyPlanScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => const ProfileFormScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
