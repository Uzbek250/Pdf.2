import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_strings.dart';
import '../../app/router.dart';
import '../../providers/translation_provider.dart';
import '../../widgets/glossy_button.dart';
import 'widgets/file_picker_card.dart';
import 'widgets/language_selector.dart';

/// Ilovaning bosh ekrani: foydalanuvchi fayl tanlaydi, maqsad tilni
/// (avtomatik yuklangan holda) tasdiqlaydi va tarjimani boshlaydi.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  File? _selectedFile;

  Future<void> _handlePickFile() async {
    final strings = AppStrings.of(context);
    final notifier = ref.read(translationTaskProvider.notifier);
    try {
      final file = await notifier.pickFile();
      if (file != null) {
        setState(() => _selectedFile = file);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.fileTooLargeOrInvalid)),
      );
    }
  }

  Future<void> _handleStartTranslation() async {
    final file = _selectedFile;
    final targetLang = ref.read(selectedLanguageProvider);
    if (file == null || targetLang == null) return;

    final notifier = ref.read(translationTaskProvider.notifier);
    // Yangi tarjima uchun oldingi holatni tozalaymiz
    notifier.reset();
    await notifier.startTranslation(file: file, targetLang: targetLang);

    if (!mounted) return;
    Navigator.of(context).pushNamed(AppRoutes.translate);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final languagesAsync = ref.watch(languagesProvider);
    final selectedLang = ref.watch(selectedLanguageProvider);

    // Backenddan tillar kelgach, agar hali hech narsa saqlanmagan bo'lsa
    // (ilk marta ishga tushirish), birinchi tilni standart qilib olamiz.
    ref.listen(languagesProvider, (previous, next) {
      next.whenData((langs) {
        if (langs.isNotEmpty) {
          ref
              .read(selectedLanguageProvider.notifier)
              .setDefaultIfEmpty(langs.first.code);
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.homeTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.homeSubtitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              FilePickerCard(
                selectedFile: _selectedFile,
                onPickFile: _handlePickFile,
              ),
              const SizedBox(height: 24),
              languagesAsync.when(
                data: (languages) => LanguageSelector(
                  languages: languages,
                  selectedCode: selectedLang,
                  onChanged: (code) {
                    ref.read(selectedLanguageProvider.notifier).selectLanguage(code);
                  },
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: LinearProgressIndicator(),
                ),
                error: (error, _) => Text(
                  strings.errorServerDown,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: GlossyButton(
                  onPressed: (_selectedFile != null && selectedLang != null)
                      ? _handleStartTranslation
                      : null,
                  icon: const Icon(Icons.translate_rounded),
                  label: Text(strings.startTranslationButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
