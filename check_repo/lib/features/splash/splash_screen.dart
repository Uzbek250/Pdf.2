import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/app_strings.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../providers/translation_provider.dart';

/// Ilova ochilganda ko'rsatiladigan qisqa salomlashish animatsiyasi.
///
/// Foydalanuvchi tanlagan interfeys tiliga mos "Salom" so'zi, tanlangan
/// dizayn uslubiga mos gradient fon va yumshoq porlash (glow) effekti
/// bilan chiqadi, so'ng avtomatik ravishda bosh ekranga o'tadi.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  Timer? _navigateTimer;

  static const _entranceDuration = Duration(milliseconds: 700);
  static const _totalSplashDuration = Duration(milliseconds: 1800);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: _entranceDuration,
    );
    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();

    // Splash bir muncha vaqt ekranda turadi, keyin bosh ekranga
    // avtomatik o'tadi — foydalanuvchidan hech qanday amal talab
    // qilinmaydi.
    _navigateTimer = Timer(_totalSplashDuration, () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    });
  }

  @override
  void dispose() {
    _navigateTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final style = ref.watch(themeStyleProvider);
    final gradientColors = style.splashGradient;
    final glowColor = style.splashGlowColor;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fade.value,
                child: Transform.scale(
                  scale: _scale.value,
                  child: child,
                ),
              );
            },
            child: Text(
              strings.helloGreeting,
              style: GoogleFonts.fraunces(
                fontSize: 46,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: glowColor.withValues(alpha: 0.85),
                    blurRadius: 30,
                  ),
                  Shadow(
                    color: glowColor.withValues(alpha: 0.45),
                    blurRadius: 60,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
