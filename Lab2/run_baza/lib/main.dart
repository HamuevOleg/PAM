import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() => runApp(const RunBazaApp());

// Palette translated from the reference's platform.css and industrial.css.
// All screens read these semantic colours, including in iOS dark mode.
ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF236649),
        brightness: brightness,
      ).copyWith(
        primary: dark ? const Color(0xFF9BD9B5) : const Color(0xFF236649),
        onPrimary: dark ? const Color(0xFF141B18) : Colors.white,
        surface: dark ? const Color(0xFF141B18) : const Color(0xFFFAFBF8),
        onSurface: dark ? const Color(0xFFEDF3EF) : const Color(0xFF202323),
        onSurfaceVariant: dark
            ? const Color(0xFFADBCB3)
            : const Color(0xFF626967),
        surfaceContainerLow: dark ? const Color(0xFF1D2822) : Colors.white,
        surfaceContainer: dark
            ? const Color(0xFF24332B)
            : const Color(0xFFEEF0E8),
        surfaceContainerHighest: dark
            ? const Color(0xFF304C3B)
            : const Color(0xFFD0DFC8),
        primaryContainer: dark
            ? const Color(0xFF253E30)
            : const Color(0xFFEDF7EE),
        onPrimaryContainer: dark
            ? const Color(0xFF9BD9B5)
            : const Color(0xFF236649),
        tertiary: dark ? const Color(0xFFFF8058) : const Color(0xFFA33D19),
        tertiaryContainer: dark
            ? const Color(0xFF392C21)
            : const Color(0xFFFFE5D8),
        onTertiaryContainer: dark
            ? const Color(0xFFFFCEB8)
            : const Color(0xFF70270F),
        outlineVariant: dark
            ? const Color(0xFF34433A)
            : const Color(0xFFDDE3DC),
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

class RunBazaApp extends StatelessWidget {
  const RunBazaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'RunBaza',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(Brightness.light),
    darkTheme: buildTheme(Brightness.dark),
    themeMode: ThemeMode.system,
    home: const HomeScreen(),
  );
}
