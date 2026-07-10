import 'package:flutter/material.dart';

import '../features/home/home_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/translate/translate_screen.dart';

/// Ilovaning marshrut (route) nomlari — bitta joyda markazlashgan, shunda
/// ekranlar orasida navigatsiya qilishda satr xatolari (typo) oldini oladi.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String home = '/';
  static const String translate = '/translate';
  static const String settings = '/settings';
}

/// `MaterialApp.onGenerateRoute` uchun markaziy marshrutlash funksiyasi.
///
/// Bu loyihada ekranlar soni kichik bo'lgani uchun `go_router` kabi
/// qo'shimcha paket o'rniga Flutter'ning o'rnatilgan `Navigator` +
/// named routes yechimi ishlatildi — bu qo'shimcha bog'liqlikni
/// kamaytiradi va CI build'ini soddalashtiradi.
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case AppRoutes.translate:
        return MaterialPageRoute(
          builder: (_) => const TranslateScreen(),
          settings: settings,
        );
      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Marshrut topilmadi: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
