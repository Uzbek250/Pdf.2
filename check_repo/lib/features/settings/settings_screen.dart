import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_strings.dart';
import '../../app/theme.dart';
import '../../providers/translation_provider.dart';

/// Sozlamalar ekrani: ilova dizayn uslubini (mavzu) va interfeys tilini
/// o'zgartirish.
///
/// Eslatma: bu yerdagi til — ilova MENYULARI tili. Hujjat tarjimasi
/// maqsad tili bosh ekranda alohida tanlanadi va alohida saqlanadi.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final currentLocale = ref.watch(uiLocaleProvider);
    final currentThemeStyle = ref.watch(themeStyleProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final languageOptions = AppLocale.values
        .map((locale) => (locale.code, locale.nativeName))
        .toList();

    final themeOptions = <(AppThemeStyle style, String label)>[
      (AppThemeStyle.professional, strings.themeProfessional),
      (AppThemeStyle.minimalist, strings.themeMinimalist),
      (AppThemeStyle.vibrant, strings.themeVibrant),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(strings.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              strings.themeSectionTitle,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: themeOptions.map((option) {
                  final (style, label) = option;
                  final selected = currentThemeStyle == style;
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: style.previewColor,
                    ),
                    title: Text(label),
                    trailing: selected
                        ? Icon(Icons.check_circle_rounded,
                            color: colorScheme.primary)
                        : null,
                    onTap: () {
                      ref.read(themeStyleProvider.notifier).setStyle(style);
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              strings.interfaceLanguage,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: languageOptions.map((option) {
                  final (code, label) = option;
                  final selected = currentLocale == code;
                  return ListTile(
                    title: Text(label),
                    trailing: selected
                        ? Icon(Icons.check_circle_rounded,
                            color: colorScheme.primary)
                        : null,
                    onTap: () {
                      ref.read(uiLocaleProvider.notifier).setLocale(code);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
