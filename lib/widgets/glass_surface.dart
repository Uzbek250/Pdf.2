import 'dart:ui';

import 'package:flutter/material.dart';

/// Shishasimon (glassmorphism) ko'rinishdagi qayta ishlatiluvchi konteyner.
///
/// Orqa fonni xiralashtiradi (blur), ustiga yarim shaffof qatlam qo'yadi
/// va yorug'roq yuqori chegara (highlight) bilan "yorug' shisha" hissini
/// beradi. Bu faqat vizual qatlam — hech qanday biznes-mantiq saqlamaydi,
/// shunchaki `child` ni chiroyli o'raydi.
class GlassSurface extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final double tintOpacity;
  final EdgeInsetsGeometry? padding;

  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blurSigma = 16,
    this.tintOpacity = 0.5,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark ? Colors.white : Colors.white;
    final edgeColor = Colors.white.withValues(alpha: isDark ? 0.14 : 0.6);
    final highlightColor = Colors.white.withValues(alpha: isDark ? 0.28 : 0.9);
    final shadowColor = Colors.black.withValues(alpha: isDark ? 0.3 : 0.06);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: tintOpacity * (isDark ? 0.1 : 0.35)),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border(
              top: BorderSide(color: highlightColor, width: 1.2),
              left: BorderSide(color: edgeColor, width: 1),
              right: BorderSide(color: edgeColor, width: 1),
              bottom: BorderSide(color: edgeColor, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
