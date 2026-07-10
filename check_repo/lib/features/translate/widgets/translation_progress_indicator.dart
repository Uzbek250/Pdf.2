import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../app/app_strings.dart';
import '../../../models/translation_task_state.dart';

/// Doiraviy progress ko'rsatkichi + joriy bosqich matni.
///
/// Har bir [TranslationStatus] uchun mos matn va ikonka ko'rsatiladi,
/// shunda foydalanuvchi jarayonning qaysi bosqichida ekanini aniq biladi
/// (masalan "PDF -> DOCX konvertatsiya" va "Tarjima qilinmoqda" alohida
/// ko'rinadi).
class TranslationProgressIndicator extends StatelessWidget {
  final TranslationProgress progress;
  final bool isUploading;

  const TranslationProgressIndicator({
    super.key,
    required this.progress,
    this.isUploading = false,
  });

  String _statusLabel(BuildContext context) {
    final strings = AppStrings.of(context);
    if (isUploading) return strings.statusUploading;
    switch (progress.status) {
      case TranslationStatus.pending:
        return strings.statusPending;
      case TranslationStatus.detectingLanguage:
        return strings.statusDetectingLanguage;
      case TranslationStatus.convertingToDocx:
        return strings.statusConvertingToDocx;
      case TranslationStatus.ocrScannedPages:
        return strings.statusOcr;
      case TranslationStatus.translating:
        return strings.statusTranslating;
      case TranslationStatus.convertingToPdf:
        return strings.statusConvertingToPdf;
      case TranslationStatus.completed:
        return strings.statusCompleted;
      case TranslationStatus.failed:
        return strings.statusFailed;
      case TranslationStatus.idle:
      case TranslationStatus.unknown:
        return strings.statusPending;
    }
  }

  IconData _statusIcon() {
    switch (progress.status) {
      case TranslationStatus.completed:
        return Icons.check_circle_rounded;
      case TranslationStatus.failed:
        return Icons.error_rounded;
      case TranslationStatus.ocrScannedPages:
        return Icons.document_scanner_rounded;
      case TranslationStatus.translating:
        return Icons.translate_rounded;
      case TranslationStatus.convertingToDocx:
      case TranslationStatus.convertingToPdf:
        return Icons.sync_rounded;
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFailed = progress.status == TranslationStatus.failed;
    final isCompleted = progress.status == TranslationStatus.completed;

    final progressColor = isFailed
        ? colorScheme.error
        : isCompleted
            ? Colors.green
            : colorScheme.primary;

    final percent = isUploading
        ? 0.05
        : (progress.progress.clamp(0, 100) / 100.0);

    return Column(
      children: [
        CircularPercentIndicator(
          radius: 90,
          lineWidth: 12,
          percent: percent.toDouble(),
          animation: true,
          animateFromLastPercent: true,
          animationDuration: 400,
          circularStrokeCap: CircularStrokeCap.round,
          backgroundColor: colorScheme.surfaceContainerHighest,
          progressColor: progressColor,
          center: isFailed || isCompleted
              ? Icon(_statusIcon(), size: 48, color: progressColor)
              : Text(
                  '${progress.progress}%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: progressColor,
                      ),
                ),
        ),
        const SizedBox(height: 20),
        Text(
          _statusLabel(context),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isFailed ? colorScheme.error : null,
              ),
          textAlign: TextAlign.center,
        ),
        if (isFailed && progress.error != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              progress.errorType != null
                  ? AppStrings.of(context).forErrorType(progress.errorType!)
                  : progress.error!,
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}
