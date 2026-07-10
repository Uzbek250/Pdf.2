/// Tarjima jarayonining umumiy bosqichlari.
///
/// Backend `status` maydonida qaytaradigan qiymatlarga mos keladi.
/// Noma'lum qiymat kelsa [unknown] ga tushadi — bu UI'ni xatolikdan
/// himoya qiladi (backend yangi status qo'shsa ham ilova qulamaydi).
enum TranslationStatus {
  idle,
  pending,
  detectingLanguage,
  convertingToDocx,
  ocrScannedPages,
  translating,
  convertingToPdf,
  completed,
  failed,
  unknown;

  static TranslationStatus fromString(String? value) {
    switch (value) {
      case 'pending':
      case 'processing':
        return TranslationStatus.pending;
      case 'detecting_language':
        return TranslationStatus.detectingLanguage;
      case 'converting_to_docx':
        return TranslationStatus.convertingToDocx;
      case 'ocr_scanned_pages':
        return TranslationStatus.ocrScannedPages;
      case 'translating':
        return TranslationStatus.translating;
      case 'converting_to_pdf':
        return TranslationStatus.convertingToPdf;
      case 'completed':
        return TranslationStatus.completed;
      case 'failed':
        return TranslationStatus.failed;
      default:
        return TranslationStatus.unknown;
    }
  }

  bool get isTerminal =>
      this == TranslationStatus.completed || this == TranslationStatus.failed;
}

/// SSE orqali kelayotgan bitta progress hodisasini (event) ifodalovchi model.
class TranslationProgress {
  final TranslationStatus status;
  final int progress; // 0-100
  final String? downloadUrl;
  final String? error;

  /// Agar xatolik `ApiException`dan kelgan bo'lsa, uning `type.name`
  /// qiymati (masalan "timeout", "rateLimited") — UI qatlami buni
  /// `AppStrings.forErrorType()` orqali joriy interfeys tiliga tarjima
  /// qiladi. Backenddan to'g'ridan-to'g'ri kelgan xatoliklar uchun null.
  final String? errorType;

  /// Yakuniy faylning haqiqiy formati (backend qaytargan, masalan
  /// "docx" yoki "pdf"). MUHIM: original fayl PDF bo'lsa ham, backend
  /// hozirda har doim "docx" qaytaradi (LibreOffice bosqichi olib
  /// tashlangan) — shuning uchun UI qatlami fayl kengaytmasini ANIQ
  /// shu maydondan olishi kerak, original fayl nomidan emas.
  final String? outputFormat;

  /// Original yuklangan fayl PDF bo'lganmi (ma'lumot uchun, UI'da
  /// "Original PDF edi, natija DOCX formatida" kabi xabar ko'rsatish
  /// uchun ishlatilishi mumkin).
  final bool? wasOriginallyPdf;

  const TranslationProgress({
    required this.status,
    required this.progress,
    this.downloadUrl,
    this.error,
    this.errorType,
    this.outputFormat,
    this.wasOriginallyPdf,
  });

  factory TranslationProgress.fromJson(Map<String, dynamic> json) {
    return TranslationProgress(
      status: TranslationStatus.fromString(json['status'] as String?),
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      downloadUrl: json['download_url'] as String?,
      error: json['error'] as String?,
      outputFormat: json['output_format'] as String?,
      wasOriginallyPdf: json['was_originally_pdf'] as bool?,
    );
  }

  factory TranslationProgress.idle() => const TranslationProgress(
        status: TranslationStatus.idle,
        progress: 0,
      );

  TranslationProgress copyWith({
    TranslationStatus? status,
    int? progress,
    String? downloadUrl,
    String? error,
    String? errorType,
    String? outputFormat,
    bool? wasOriginallyPdf,
  }) {
    return TranslationProgress(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      error: error ?? this.error,
      errorType: errorType ?? this.errorType,
      outputFormat: outputFormat ?? this.outputFormat,
      wasOriginallyPdf: wasOriginallyPdf ?? this.wasOriginallyPdf,
    );
  }
}

/// Yuklangan va tarjima qilinayotgan faylga oid to'liq holat (state).
///
/// Bu klass Riverpod provider ichida saqlanadi va UI shu orqali qayta
/// quriladi (rebuild).
class TranslationTaskState {
  final String? taskId;
  final String? originalFileName;
  final String? targetLangCode;
  final TranslationProgress progress;
  final String? localDownloadedFilePath;
  final bool isUploading;

  const TranslationTaskState({
    this.taskId,
    this.originalFileName,
    this.targetLangCode,
    this.progress = const TranslationProgress(
      status: TranslationStatus.idle,
      progress: 0,
    ),
    this.localDownloadedFilePath,
    this.isUploading = false,
  });

  bool get isActive =>
      isUploading ||
      (taskId != null && !progress.status.isTerminal) ||
      progress.status == TranslationStatus.pending;

  bool get isCompleted => progress.status == TranslationStatus.completed;
  bool get isFailed => progress.status == TranslationStatus.failed;

  TranslationTaskState copyWith({
    String? taskId,
    String? originalFileName,
    String? targetLangCode,
    TranslationProgress? progress,
    String? localDownloadedFilePath,
    bool? isUploading,
    bool clearTaskId = false,
  }) {
    return TranslationTaskState(
      taskId: clearTaskId ? null : (taskId ?? this.taskId),
      originalFileName: originalFileName ?? this.originalFileName,
      targetLangCode: targetLangCode ?? this.targetLangCode,
      progress: progress ?? this.progress,
      localDownloadedFilePath:
          localDownloadedFilePath ?? this.localDownloadedFilePath,
      isUploading: isUploading ?? this.isUploading,
    );
  }

  static const empty = TranslationTaskState();
}
