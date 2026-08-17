import 'package:flutter/material.dart';

class StarBackground extends StatelessWidget {
  final Widget child;
  final String imagePath;
  final Color overlayColor;
  final double overlayOpacity;

  const StarBackground({
    super.key,
    required this.child,
    this.imagePath = 'assets/images/space_background.png',
    this.overlayColor = const Color(0xFF000000),
    this.overlayOpacity = 0.65,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.black),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF02070D),
                        Color(0xFF0A1623),
                        Color(0xFF111827),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: overlayColor.withValues(alpha: overlayOpacity),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
