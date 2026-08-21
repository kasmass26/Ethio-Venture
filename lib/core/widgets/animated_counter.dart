import 'package:flutter/material.dart';

/// A widget that animates a number from 0 up to [end].
///
/// Useful for dashboard metric cards — the value "counts up" when it first
/// appears, giving a real-time, data-driven feel.
///
/// Example:
/// ```dart
/// AnimatedCounter(
///   end: 248,
///   suffix: '',
///   style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
/// )
/// ```
class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({
    super.key,
    required this.end,
    this.prefix = '',
    this.suffix = '',
    this.style,
    this.duration = const Duration(milliseconds: 1200),
    this.curve = Curves.easeOutCubic,
  });

  /// The target number to count up to.
  final int end;

  /// Optional text before the number (e.g. "$").
  final String prefix;

  /// Optional text after the number (e.g. "%").
  final String suffix;

  /// Text style applied to the formatted string.
  final TextStyle? style;

  /// How long the count-up takes.
  final Duration duration;

  /// The easing curve.
  final Curve curve;

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _buildAnimation();
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.end != widget.end) {
      _buildAnimation();
      _controller
        ..reset()
        ..forward();
    }
  }

  void _buildAnimation() {
    _animation = IntTween(begin: 0, end: widget.end).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Text(
          '${widget.prefix}${_animation.value}${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}
