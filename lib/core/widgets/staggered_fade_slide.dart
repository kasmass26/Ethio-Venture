import 'package:flutter/material.dart';

/// Wraps a child so it fades in + slides up with a staggered delay.
///
/// Use this around each dashboard section to create a cascading entrance
/// effect where content reveals itself top-to-bottom.
///
/// Example:
/// ```dart
/// StaggeredFadeSlide(
///   index: 0,           // first item
///   totalItems: 5,      // how many siblings there are
///   child: MyWidget(),
/// )
/// ```
class StaggeredFadeSlide extends StatefulWidget {
  const StaggeredFadeSlide({
    super.key,
    required this.index,
    required this.child,
    this.totalItems = 6,
    this.totalDuration = const Duration(milliseconds: 1400),
    this.slideOffset = 24.0,
  });

  /// Zero-based index — determines the stagger delay.
  final int index;

  /// Total number of staggered siblings (used to distribute intervals).
  final int totalItems;

  /// Duration for the full stagger sequence.
  final Duration totalDuration;

  /// How many pixels the child slides up from.
  final double slideOffset;

  final Widget child;

  @override
  State<StaggeredFadeSlide> createState() => _StaggeredFadeSlideState();
}

class _StaggeredFadeSlideState extends State<StaggeredFadeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.totalDuration,
    );

    // Each item occupies a proportional slice of the timeline.
    final sliceDuration = 1.0 / widget.totalItems;
    final start = (widget.index * sliceDuration * 0.7).clamp(0.0, 0.85);
    final end = (start + sliceDuration + 0.15).clamp(start + 0.1, 1.0);

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    _offset = Tween<Offset>(
      begin: Offset(0, widget.slideOffset),
      end: Offset.zero,
    ).animate(curved);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: _offset.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
