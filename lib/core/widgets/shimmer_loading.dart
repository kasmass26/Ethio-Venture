import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Animated shimmer placeholder that sweeps a light gradient across itself.
///
/// Use this inside loading states to replace static grey containers with a
/// polished, premium-feeling animation.
///
/// Example:
/// ```dart
/// ShimmerLoading(
///   width: 200,
///   height: 16,
///   borderRadius: 8,
/// )
/// ```
class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
    this.baseColor,
    this.highlightColor,
  });

  final double? width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.baseColor ?? AppColors.surfaceVariant;
    final highlight =
        widget.highlightColor ?? AppColors.surface;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(-1.0 + 2.0 * _controller.value + 1.0, 0),
              colors: [base, highlight, base],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// A shimmer placeholder shaped like a card, useful for loading rails.
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({
    super.key,
    this.width = 250,
    this.height = 200,
    this.borderRadius = 20,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerLoading(width: 44, height: 44, borderRadius: 14),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading(width: 80, height: 14, borderRadius: 4),
                    const SizedBox(height: 6),
                    ShimmerLoading(width: 110, height: 10, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ShimmerLoading(width: 140, height: 16, borderRadius: 4),
          const SizedBox(height: 12),
          ShimmerLoading(width: 100, height: 24, borderRadius: 8),
          const Spacer(),
          ShimmerLoading(height: 38, borderRadius: 12),
        ],
      ),
    );
  }
}
