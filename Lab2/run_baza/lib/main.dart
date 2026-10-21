import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'router.dart';

import 'package:provider/provider.dart';

import 'data/mock_repositories.dart';
import 'data/race_repository.dart';
import 'data/plan_repository.dart';
import 'data/offer_repository.dart';
import 'data/request_repository.dart';
import 'data/profile_repository.dart';
import 'data/runner_profile.dart';
import 'models/race_catalog.dart';
import 'models/plan_model.dart';
import 'models/transfer_models.dart';
import 'models/profile_model.dart';

void main() => runApp(const RunBazaApp());

// Samepace reference: warm paper/orange in light, graphite/lime in dark.
// All screens read these semantic colours, including in iOS dark mode.
ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: const Color(0xFFA44920),
        brightness: brightness,
      ).copyWith(
        primary: dark ? const Color(0xFFE4FF00) : const Color(0xFFA44920),
        onPrimary: dark ? const Color(0xFF141414) : Colors.white,
        surface: dark ? const Color(0xFF141414) : const Color(0xFFF5F1E8),
        onSurface: dark ? const Color(0xFFF8F8F5) : const Color(0xFF202020),
        onSurfaceVariant: dark
            ? const Color(0xFFB8B8B4)
            : const Color(0xFF69645C),
        surfaceContainerLow: dark ? const Color(0xFF202020) : Colors.white,
        surfaceContainer: dark
            ? const Color(0xFF2B2B2B)
            : const Color(0xFFEDE7DC),
        surfaceContainerHighest: dark
            ? const Color(0xFF393D26)
            : const Color(0xFFF0DDC8),
        primaryContainer: dark
            ? const Color(0xFF34391C)
            : const Color(0xFFFAE9DB),
        onPrimaryContainer: dark
            ? const Color(0xFFE4FF00)
            : const Color(0xFFA44920),
        tertiary: dark ? const Color(0xFFFF8058) : const Color(0xFFA33D19),
        tertiaryContainer: dark
            ? const Color(0xFF392C21)
            : const Color(0xFFFFE5D8),
        onTertiaryContainer: dark
            ? const Color(0xFFFFCEB8)
            : const Color(0xFF70270F),
        outlineVariant: dark
            ? const Color(0xFF40403B)
            : const Color(0xFFDED6CA),
      );
  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  final text = base.textTheme
      .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface)
      .copyWith(
        displaySmall: TextStyle(
          fontSize: 42,
          height: 1.02,
          letterSpacing: -1.8,
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
        headlineLarge: TextStyle(
          fontSize: 34,
          height: 1.07,
          letterSpacing: -1.3,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          height: 1.12,
          letterSpacing: -0.9,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          height: 1.2,
          letterSpacing: -0.6,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          height: 1.25,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: scheme.onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.45,
          color: scheme.onSurface,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w700,
          color: scheme.onSurfaceVariant,
        ),
      );
  const shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(4)),
  );
  return base.copyWith(
    textTheme: text,
    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primaryContainer,
      labelTextStyle: const WidgetStatePropertyAll(
        TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      ),
    ),
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleMedium,
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(44, 50),
        shape: shape,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(44, 50),
        shape: shape,
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      errorMaxLines: 3,
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
    ),
  );
}

class RunBazaApp extends StatefulWidget {
  final GoRouter? router;
  const RunBazaApp({super.key, this.router});
  @override
  State<RunBazaApp> createState() => _RunBazaAppState();
}

class _RunBazaAppState extends State<RunBazaApp> {
  late final GoRouter _router = widget.router ?? createRouter();
  @override
  void dispose() {
    if (widget.router == null) _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RunBazaScope(
    child: Builder(
      builder: (context) {
        final appearance = context.watch<ProfileModel>().profile?.appearance;
        return MaterialApp.router(
          title: 'RunBaza',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: switch (appearance) {
            AppAppearance.light => ThemeMode.light,
            AppAppearance.dark => ThemeMode.dark,
            _ => ThemeMode.system,
          },
          routerConfig: _router,
        );
      },
    ),
  );
}

/// The source is selected here. Screens depend only on state models.
class RunBazaScope extends StatefulWidget {
  final Widget child;
  final Duration latency;
  const RunBazaScope({
    super.key,
    required this.child,
    this.latency = const Duration(milliseconds: 800),
  });
  @override
  State<RunBazaScope> createState() => _RunBazaScopeState();
}

class _RunBazaScopeState extends State<RunBazaScope> {
  final _failure = MockFailure();
  late final _races = MockRaceRepository(_failure, latency: widget.latency);
  late final _plan = MockPlanRepository(_failure, latency: widget.latency);
  late final _offers = MockOfferRepository(_failure, latency: widget.latency);
  late final _requests = MockRequestRepository(
    _failure,
    latency: widget.latency,
  );
  late final _profile = MockProfileRepository(
    _failure,
    latency: widget.latency,
  );

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      Provider<MockRaceRepository>.value(value: _races),
      Provider<RaceRepository>.value(value: _races),
      Provider<PlanRepository>.value(value: _plan),
      Provider<OfferRepository>.value(value: _offers),
      Provider<RequestRepository>.value(value: _requests),
      Provider<ProfileRepository>.value(value: _profile),
      ChangeNotifierProvider(
        lazy: false,
        create: (context) =>
            RaceCatalog(context.read<RaceRepository>())..load(),
      ),
      ChangeNotifierProvider(
        lazy: false,
        create: (context) => PlanModel(context.read<PlanRepository>())..load(),
      ),
      ChangeNotifierProvider(
        lazy: false,
        create: (context) =>
            OfferModel(context.read<OfferRepository>())..load(),
      ),
      ChangeNotifierProvider(
        lazy: false,
        create: (context) =>
            RequestModel(context.read<RequestRepository>())..load(),
      ),
      ChangeNotifierProvider(
        lazy: false,
        create: (context) =>
            ProfileModel(context.read<ProfileRepository>())..load(),
      ),
    ],
    child: widget.child,
  );
}
