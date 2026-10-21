import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'models/profile_model.dart';
import 'screens/profile_form_screen.dart';

import 'widgets/app_shell.dart';
import 'data/runner_identity.dart';
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

GoRouter createRouter({String initialLocation = '/login'}) {
  return GoRouter(
    initialLocation: initialLocation,
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(
          onSignedIn: (email) {
            final model = context.read<ProfileModel>();
            final current = model.profile;
            model.startSession(
              RunnerIdentity(
                name: current?.email == email
                    ? current!.name
                    : email.split('@').first,
                email: email,
              ),
            );
          },
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterScreen(
          onRegistered: (profile) =>
              context.read<ProfileModel>().startSession(profile),
        ),
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
