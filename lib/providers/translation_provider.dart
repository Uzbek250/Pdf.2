import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../models/language_model.dart';
import '../models/translation_task_state.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

/// Butun ilova bo'ylab bitta [ApiService] instansi.
final apiServiceProvider = Provider<ApiService>((ref) {
  final service = ApiService();
  ref.onDispose(service.dispose);
  return service;
});

/// [StorageService] uchun provider (singleton, allaqachon main()da init qilingan).
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService.instance;
});

/// Backenddan qo'llab-quvvatlanadigan tillar ro'yxatini oladi va keshlaydi.
///
/// `FutureProvider` avtomatik ravishda loading/error/data holatlarini
/// boshqaradi — UI qatlamida `.when(...)` orqali ishlatiladi.
final languagesProvider = FutureProvider<List<LanguageModel>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getLanguages();
});

/// Foydalanuvchi hozir tanlagan (yoki avtomatik yuklangan) maqsad til kodi.
///
/// MAJBURIY TALAB: ilova ishga tushganda SharedPreferences'dan oxirgi
/// tanlangan til avtomatik yuklanadi — foydalanuvchidan qayta so'ralmaydi.
class SelectedLanguageNotifier extends StateNotifier<String?> {
  final StorageService _storage;

  SelectedLanguageNotifier(this._storage) : super(null) {
    _loadSaved();
  }

  void _loadSaved() {
    state = _storage.getLastTargetLang();
  }

  /// Foydalanuvchi yangi til tanlaganda chaqiriladi — darhol saqlanadi.
  Future<void> selectLanguage(String langCode) async {
    state = langCode;
    await _storage.saveLastTargetLang(langCode);
  }

  /// Agar hech qanday til saqlanmagan bo'lsa (ilk marta ishga tushirish),
  /// standart tilni o'rnatadi.
  Future<void> setDefaultIfEmpty(String defaultCode) async {
    if (state == null) {
      await selectLanguage(defaultCode);
    }
  }
}

final selectedLanguageProvider =
    StateNotifierProvider<SelectedLanguageNotifier, String?>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SelectedLanguageNotifier(storage);
});

/// Ilova interfeysi tili (UZ/RU/EN) — SharedPreferences orqali saqlanadi.
class UiLocaleNotifier extends StateNotifier<String> {
  final StorageService _storage;

  UiLocaleNotifier(this._storage) : super(_storage.getUiLocale() ?? 'uz');

  Future<void> setLocale(String code) async {
    state = code;
    await _storage.saveUiLocale(code);
  }
}

final uiLocaleProvider = StateNotifierProvider<UiLocaleNotifier, String>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return UiLocaleNotifier(storage);
});

/// Joriy tarjima vazifasining to'liq holatini boshqaruvchi notifier.
///
/// Fayl tanlashdan tortib, yuklash, SSE orqali progressni kuzatish va
/// yakuniy faylni yuklab olishgacha bo'lgan butun oqimni shu klass
/// boshqaradi.
class TranslationTaskNotifier extends StateNotifier<TranslationTaskState> {
  final ApiService _api;
  StreamSubscription<TranslationProgress>? _progressSubscription;

  TranslationTaskNotifier(this._api) : super(TranslationTaskState.empty);

  /// Fayl tanlash dialogini ochadi (faqat PDF va DOCX).
  ///
  /// Foydalanuvchi bekor qilsa `null` qaytaradi.
  Future<File?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return null;
    final path = result.files.single.path;
    if (path == null) return null;
    return File(path);
  }

  /// Tanlangan faylni yuklaydi va tarjima jarayonini boshlaydi.
  ///
  /// Ichki oqim:
  /// 1. `/api/translate` ga fayl yuboriladi -> `task_id` olinadi.
  /// 2. SSE orqali progress kuzatiladi.
  /// 3. `completed` bo'lganda avtomatik yuklab olish boshlanishi mumkin
  ///    (buni chaqiruvchi UI [downloadResult] orqali alohida so'raydi).
  Future<void> startTranslation({
    required File file,
    required String targetLang,
  }) async {
    _progressSubscription?.cancel();

    final fileName = file.path.split(Platform.pathSeparator).last;
    state = TranslationTaskState(
      originalFileName: fileName,
      targetLangCode: targetLang,
      isUploading: true,
      progress: TranslationProgress.idle(),
    );

    try {
      final uploadResult = await _api.uploadFile(
        file: file,
        targetLang: targetLang,
      );

      state = state.copyWith(
        taskId: uploadResult.taskId,
        isUploading: false,
        progress: const TranslationProgress(
          status: TranslationStatus.pending,
          progress: 0,
        ),
      );

      _listenToProgress(uploadResult.taskId);
    } on ApiException catch (e) {
      state = state.copyWith(
        isUploading: false,
        progress: TranslationProgress(
          status: TranslationStatus.failed,
          progress: 0,
          error: e.message,
          errorType: e.type.name,
        ),
      );
    }
  }

  void _listenToProgress(String taskId) {
    _progressSubscription = _api.watchProgress(taskId).listen(
      (progress) {
        state = state.copyWith(progress: progress);
      },
      onError: (Object error) {
        final message =
            error is ApiException ? error.message : 'Noma\'lum xatolik.';
        final errorTypeName = error is ApiException ? error.type.name : null;
        state = state.copyWith(
          progress: TranslationProgress(
            status: TranslationStatus.failed,
            progress: state.progress.progress,
            error: message,
            errorType: errorTypeName,
          ),
        );
      },
    );
  }

  /// Tayyor faylni qurilmaning "Downloads" (yoki ilova hujjatlar) papkasiga
  /// yuklab saqlaydi va lokal yo'lni state'ga yozadi.
  Future<File?> downloadResult() async {
    final taskId = state.taskId;
    if (taskId == null || !state.isCompleted) return null;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final originalName = state.originalFileName ?? 'document';
      final ext = originalName.contains('.')
          ? originalName.split('.').last
          : 'pdf';
      final baseName = originalName.contains('.')
          ? originalName.substring(0, originalName.lastIndexOf('.'))
          : originalName;
      final savePath =
          '${dir.path}/${baseName}_translated_${state.targetLangCode}.$ext';

      final file = await _api.downloadFile(
        taskId: taskId,
        savePath: savePath,
      );

      state = state.copyWith(localDownloadedFilePath: file.path);
      return file;
    } on ApiException catch (e) {
      state = state.copyWith(
        progress: state.progress.copyWith(error: e.message),
      );
      return null;
    }
  }

  /// Holatni tozalab, yangi tarjima uchun tayyorlaydi.
  void reset() {
    _progressSubscription?.cancel();
    _progressSubscription = null;
    state = TranslationTaskState.empty;
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    super.dispose();
  }
}

final translationTaskProvider =
    StateNotifierProvider<TranslationTaskNotifier, TranslationTaskState>(
        (ref) {
  final api = ref.watch(apiServiceProvider);
  return TranslationTaskNotifier(api);
});
