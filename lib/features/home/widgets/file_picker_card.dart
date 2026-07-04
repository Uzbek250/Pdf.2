import 'dart:io';

import 'package:flutter/material.dart';

import '../../../app/app_strings.dart';

/// Tanlangan faylni ko'rsatuvchi yoki fayl tanlashga taklif qiluvchi karta.
class FilePickerCard extends StatelessWidget {
  final File? selectedFile;
  final VoidCallback onPickFile;

  const FilePickerCard({
    super.key,
    required this.selectedFile,
    required this.onPickFile,
  });

  IconData _iconForFile(String path) {
    final ext = path.toLowerCase();
    if (ext.endsWith('.pdf')) return Icons.picture_as_pdf_rounded;
    if (ext.endsWith('.docx')) return Icons.description_rounded;
    return Icons.insert_drive_file_rounded;
  }

  String _fileName(String path) => path.split(Platform.pathSeparator).last;

  String _fileSizeLabel(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(0)} KB';
      }
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final file = selectedFile;

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPickFile,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant,
              width: 1.2,
            ),
          ),
          child: file == null
              ? Column(
                  children: [
                    Icon(
                      Icons.upload_file_rounded,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      strings.pickFileButton,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PDF / DOCX',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(
                        _iconForFile(file.path),
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fileName(file.path),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _fileSizeLabel(file),
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit_rounded, color: colorScheme.primary),
                  ],
                ),
        ),
      ),
    );
  }
}
