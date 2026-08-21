import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

/// Standard branded App Logo widget displaying the official Ethio Venture icon.
///
/// Features support for custom dimensions, rounded corners or circular shape,
/// subtle border framing, and ambient drop shadows.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 48,
    this.borderRadius,
    this.isCircular = false,
    this.showShadow = false,
    this.showBorder = false,
    this.borderColor,
    this.backgroundColor,
  });

  /// Width and height of the logo in logical pixels.
  final double size;

  /// Custom corner radius. Defaults to 22% of [size] if not specified.
  final double? borderRadius;

  /// Whether the logo should be clipped to a perfect circle.
  final bool isCircular;

  /// Whether to render a soft, ambient glow shadow behind the logo.
  final bool showShadow;

  /// Whether to render a fine border around the logo container.
  final bool showBorder;

  /// Color of the optional border.
  final Color? borderColor;

  /// Background color behind the image.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? (size * 0.22);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBorderColor = borderColor ??
        (isDark
            ? AppColors.primary.withValues(alpha: 0.25)
            : AppColors.primary.withValues(alpha: 0.15));

    final effectiveBgColor = backgroundColor ??
        (isDark ? const Color(0xFF07121E) : Colors.transparent);

    Widget imageWidget = Image.asset(
      AppConstants.appLogo,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: size,
          height: size,
          color: AppColors.primarySoft,
          child: Icon(
            Icons.hub_rounded,
            size: size * 0.55,
            color: AppColors.primary,
          ),
        );
      },
    );

    if (isCircular) {
      imageWidget = ClipOval(child: imageWidget);
    } else if (effectiveRadius > 0) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(effectiveRadius),
        child: imageWidget,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircular ? null : BorderRadius.circular(effectiveRadius),
        border: showBorder ? Border.all(color: defaultBorderColor, width: 1.2) : null,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.18),
                  blurRadius: size * 0.35,
                  spreadRadius: 2,
                  offset: Offset(0, size * 0.08),
                ),
              ]
            : null,
      ),
      child: imageWidget,
    );
  }
}
