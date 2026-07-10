import 'package:flutter/material.dart';

import '../../../app/app_strings.dart';
import '../../../models/language_model.dart';

/// Maqsad tilni tanlash uchun dropdown selektor.
///
/// Oxirgi tanlangan til [selectedCode] orqali oldindan tanlangan holda
/// keladi — foydalanuvchi har safar qayta tanlashi shart emas (MAJBURIY
/// TALAB: avtomatik oldingi tilni tanlash).
class LanguageSelector extends StatelessWidget {
  final List<LanguageModel> languages;
  final String? selectedCode;
  final ValueChanged<String> onChanged;

  const LanguageSelector({
    super.key,
    required this.languages,
    required this.selectedCode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    // Agar saqlangan til ro'yxatda topilmasa (masalan backend tillar
    // ro'yxatini o'zgartirgan bo'lsa), xavfsiz fallback qilamiz.
    final validSelection = languages.any((l) => l.code == selectedCode)
        ? selectedCode
        : (languages.isNotEmpty ? languages.first.code : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.targetLanguageLabel,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: validSelection,
              isExpanded: true,
              icon: const Icon(Icons.expand_more_rounded),
              borderRadius: BorderRadius.circular(14),
              items: languages
                  .map(
                    (lang) => DropdownMenuItem<String>(
                      value: lang.code,
                      child: Row(
                        children: [
                          Text(
                            lang.nameNative,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${lang.code.toUpperCase()})',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}
