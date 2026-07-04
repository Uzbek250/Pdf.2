import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_strings.dart';
import '../../providers/translation_provider.dart';

/// Sozlamalar ekrani: ilova interfeysi tilini (UZ/RU/EN) o'zgartirish.
///
/// Eslatma: bu yerdagi til — ilova MENYULARI tili. Hujjat tarjimasi
/// maqsad tili bosh ekranda alohida tanlanadi va alohida saqlanadi.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final currentLocale = ref.watch(uiLocaleProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final options = <(String code, String label)>[
      ('uz', "O'zbekcha"),
      ('ru', 'Русский'),
      ('en', 'English'),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(strings.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
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
                children: options.map((option) {
                  final (code, label) = option;
                  final selected = currentLocale == code;
                  return ListTile(
                    title: Text(label),
                    trailing: selected
                        ? Icon(Icons.check_circle_rounded, color: colorScheme.primary)
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
