import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_strings.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'providers/translation_provider.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SharedPreferences ilova ishga tushishidan oldin tayyor bo'lishi kerak,
  // aks holda oxirgi tanlangan til va UI tili to'g'ri yuklanmaydi.
  await StorageService.instance.init();

  runApp(const ProviderScope(child: DocTranslatorApp()));
}

/// Ildiz (root) widget: Material Design 3 tema va tanlangan interfeys
/// tiliga mos [AppLocaleScope] bilan o'raladi.
class DocTranslatorApp extends ConsumerWidget {
  const DocTranslatorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeCode = ref.watch(uiLocaleProvider);
    final locale = AppLocaleX.fromCode(localeCode);

    return AppLocaleScope(
      locale: locale,
      child: MaterialApp(
        title: 'Document Translator',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
