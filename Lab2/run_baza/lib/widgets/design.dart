import 'package:flutter/material.dart';

void openScreen(BuildContext context, Widget screen) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));

class Eyebrow extends StatelessWidget {
  final String text;
  const Eyebrow(this.text, {super.key});
  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: Theme.of(context).textTheme.labelSmall);
}

class SectionHeading extends StatelessWidget {
  final String number, title;
  final Widget? trailing;
  const SectionHeading(this.number, this.title, {super.key, this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 28, bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            if (trailing != null) trailing! else Eyebrow(number),
          ],
        ),
      ],
    ),
  );
}

class CutPanel extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;
  const CutPanel({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(20),
  });
  @override
  Widget build(BuildContext context) => ClipPath(
    clipper: const _CutCorners(),
    child: ColoredBox(
      color: color ?? Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(padding: padding, child: child),
    ),
  );
}

class _CutCorners extends CustomClipper<Path> {
  const _CutCorners();
  @override
  Path getClip(Size s) => Path()
    ..moveTo(9, 0)
    ..lineTo(s.width - 9, 0)
    ..lineTo(s.width, 9)
    ..lineTo(s.width, s.height - 9)
    ..lineTo(s.width - 9, s.height)
    ..lineTo(9, s.height)
    ..lineTo(0, s.height - 9)
    ..lineTo(0, 9)
    ..close();
  @override
  bool shouldReclip(_CutCorners old) => false;
}

class Metric extends StatelessWidget {
  final String value, label;
  const Metric(this.value, this.label, {super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 4),
      Text(
        label,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ],
  );
}
