import 'package:flutter/material.dart';

class RunnerAvatar extends StatelessWidget {
  final String name;
  final int variant;
  final double size;
  const RunnerAvatar({
    super.key,
    required this.name,
    this.variant = 0,
    this.size = 72,
  });
  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s.characters.first.toUpperCase())
        .join();
    final colors = [
      const Color(0xFFE9F29B),
      const Color(0xFFF0BC91),
      const Color(0xFFB8D5D1),
      const Color(0xFFD6C5E6),
    ];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors[variant % colors.length],
        borderRadius: BorderRadius.circular(size * .32),
        border: Border.all(
          color: Colors.white.withValues(alpha: .35),
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? 'RB' : initials,
        textScaler: TextScaler.noScaling,
        style: TextStyle(
          color: const Color(0xFF24251C),
          fontSize: size * .32,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
      ),
    );
  }
}
