import 'package:flutter/material.dart';

/// Fades and slides a child up into place over one slice ([interval]) of a shared,
/// already-running [animation] - used to stagger a screen's entrance (logo, then
/// heading, then form) instead of every element appearing at once.
class EntranceFade extends StatelessWidget {
  final Animation<double> animation;
  final Interval interval;
  final Widget child;
  final double offsetY;

  const EntranceFade({
    super.key,
    required this.animation,
    required this.interval,
    required this.child,
    this.offsetY = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: animation, curve: interval);
    return AnimatedBuilder(
      animation: curved,
      child: child,
      builder: (context, child) => Opacity(
        opacity: curved.value,
        child: Transform.translate(offset: Offset(0, (1 - curved.value) * offsetY), child: child),
      ),
    );
  }
}
