import 'package:flutter/material.dart';

import 'glass_surface.dart';

/// Burtib chiqqan, yaltiroq (glossy) ko'rinishdagi asosiy amal tugmasi.
///
/// Bosilganda yengil "siqilish" animatsiyasi bilan tabiiy taktil hissi
/// beradi. Faqat vizual komponent — chaqiruvchi tomon o'z `onPressed`
/// mantig'ini xuddi oddiy `FilledButton.icon` kabi uzatadi.
class GlossyButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget label;
  final Widget? icon;
  final Color? tintColor;

  const GlossyButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.tintColor,
  });

  @override
  State<GlossyButton> createState() => _GlossyButtonState();
}

class _GlossyButtonState extends State<GlossyButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onPressed == null) return;
    setState(() => _pressed = value);
  }

  Color _onColorFor(Color background) {
    return background.computeLuminance() > 0.5
        ? const Color(0xFF1A1A18)
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = widget.onPressed != null;
    final tint = widget.tintColor ?? colorScheme.primary;
    final onTint = _onColorFor(tint);

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: enabled ? 1.0 : 0.45,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(tint, Colors.white, 0.22)!,
                  tint,
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: tint.withValues(alpha: 0.45),
                  blurRadius: _pressed ? 6 : 18,
                  offset: Offset(0, _pressed ? 2 : 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  IconTheme(
                    data: IconThemeData(color: onTint, size: 20),
                    child: widget.icon!,
                  ),
                  const SizedBox(width: 10),
                ],
                DefaultTextStyle.merge(
                  style: TextStyle(
                    color: onTint,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  child: widget.label,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ikkinchi darajali amal uchun shishasimon (glass) ko'rinishdagi tugma —
/// `OutlinedButton.icon` o'rnini bosuvchi vizual variant.
class GlossyOutlineButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget label;
  final Widget? icon;

  const GlossyOutlineButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
  });

  @override
  State<GlossyOutlineButton> createState() => _GlossyOutlineButtonState();
}

class _GlossyOutlineButtonState extends State<GlossyOutlineButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onPressed == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: enabled ? 1.0 : 0.45,
          duration: const Duration(milliseconds: 150),
          child: GlassSurface(
            borderRadius: 18,
            blurSigma: 10,
            padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  IconTheme(
                    data: IconThemeData(color: colorScheme.primary, size: 20),
                    child: widget.icon!,
                  ),
                  const SizedBox(width: 10),
                ],
                DefaultTextStyle.merge(
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  child: widget.label,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
