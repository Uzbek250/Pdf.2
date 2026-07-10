import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../app/theme.dart';
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

/// Ilovaning tanlangan dizayn uslubi (professional / minimalist / vibrant)
/// — SharedPreferences orqali saqlanadi, shunda foydalanuvchi bir marta
/// Sozlamalardan tanlagach, keyingi ochilishlarda ham o'sha uslub turadi.
class ThemeStyleNotifier extends StateNotifier<AppThemeStyle> {
  final StorageService _storage;

  ThemeStyleNotifier(this._storage)
      : super(AppThemeStyleX.fromCode(_storage.getThemeStyle()));

  Future<void> setStyle(AppThemeStyle style) async {
    state = style;
    await _storage.saveThemeStyle(style.code);
  }
}

final themeStyleProvider =
    StateNotifierProvider<ThemeStyleNotifier, AppThemeStyle>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ThemeStyleNotifier(storage);
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

  /// Tayyor faylni qurilmaning HAQIQIY "Downloads" papkasiga yuklab
  /// saqlaydi va lokal yo'lni state'ga yozadi.
  ///
  /// MUHIM: avvalgi versiyada `getApplicationDocumentsDirectory()`
  /// ishlatilgan edi — bu Android'da ilova xususiy (sandbox) papkasiga
  /// ishora qiladi (masalan `/data/data/<paket>/app_flutter/`). Bu joy
  /// faqat ilovaning o'ziga ko'rinadi: na Fayllar ilovasida, na boshqa
  /// dasturlarda (WPS, Google Drive) topib bo'lmaydi. Foydalanuvchi
  /// "Yuklab olish" tugmasini bossa ham, fayl texnik jihatdan saqlanadi,
  /// lekin qurilmaning umumiy xotirasida "yo'qolgandek" bo'lib qoladi —
  /// faqat ilovaning o'zi orqali (`_handleOpenExistingFile`) ochish
  /// mumkin bo'lib qoladi.
  ///
  /// Bu funksiya endi Android'da haqiqiy ommaviy Download papkasiga
  /// (`/storage/emulated/0/Download`) yozadi — bu foydalanuvchi
  /// kutayotgan, standart Fayllar ilovasida ko'rinadigan joy.
  Future<File?> downloadResult() async {
    final taskId = state.taskId;
    if (taskId == null || !state.isCompleted) return null;

    try {
      final originalName = state.originalFileName ?? 'document';
      final baseName = originalName.contains('.')
          ? originalName.substring(0, originalName.lastIndexOf('.'))
          : originalName;

      // MUHIM: fayl kengaytmasini backend qaytargan `outputFormat`dan
      // olamiz, ORIGINAL fayl nomidan emas. Sabab: agar kirish PDF
      // bo'lsa ham, backend hozirda natijani DOCX formatida qaytaradi
      // (LibreOffice qayta-konvertatsiya bosqichi olib tashlangan).
      final ext = state.progress.outputFormat ?? _fallbackExtension(originalName);
      final fileName = '${baseName}_translated_${state.targetLangCode}.$ext';

      final downloadsDir = await _resolvePublicDownloadsDirectory();
      final savePath = '${downloadsDir.path}/$fileName';

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

  /// Qurilmaning HAQIQIY, foydalanuvchiga ko'rinadigan Downloads
  /// papkasini aniqlaydi.
  ///
  /// Android'da: to'g'ridan-to'g'ri `/storage/emulated/0/Download`ga
  /// murojaat qilinadi. Bu maxsus, tizim tomonidan "umumiy" (shared)
  /// deb tan olingan papka — Android 10+ scoped storage rejimida ham,
  /// ilovalar bu papkaga alohida `MANAGE_EXTERNAL_STORAGE` ruxsatisiz
  /// yoza oladi (bu boshqa ixtiyoriy papkalardan farqli holat).
  ///
  /// iOS'da esa umumiy "Downloads" tushunchasi yo'q (iOS'da ilovalar
  /// bir-birining fayllarini ko'rmaydi) — shu sabab iOS uchun ilova
  /// hujjatlar papkasiga qaytamiz, bu yerda foydalanuvchi "Files"
  /// ilovasi orqali "On My iPhone > <ilova nomi>" bo'limida topadi.
  Future<Directory> _resolvePublicDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // Android 13+ da media ruxsatlari alohida turkumlangan, lekin
      // to'g'ridan-to'g'ri /storage/emulated/0/Download yo'liga yozish
      // uchun maxsus runtime ruxsat so'ralishi shart emas (bu WRITE
      // qoidalaridan chetlangan umumiy papka). Ammo eski Android
      // versiyalari (10 dan past) uchun ehtiyot chorasi sifatida
      // ruxsatni so'raymiz — agar berilmasa, ilova xususiy papkaga
      // qaytadi (fallback), hech bo'lmaganda funksiya ishlamay
      // qolmaydi.
      try {
        final status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
      } catch (_) {
        // Ruxsat so'rash muvaffaqiyatsiz bo'lsa ham davom etamiz —
        // zamonaviy Android versiyalarida bu qadam shart emas.
      }

      const downloadsPath = '/storage/emulated/0/Download';
      final downloadsDir = Directory(downloadsPath);
      try {
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        return downloadsDir;
      } catch (_) {
        // Agar umumiy Download papkasiga yozib bo'lmasa (kamdan-kam,
        // masalan juda cheklangan qurilmalarda), ilova xususiy
        // papkasiga xavfsiz qaytadi — foydalanuvchi hech bo'lmaganda
        // ilova ichidan faylni ochishi mumkin bo'lib qoladi.
        return getApplicationDocumentsDirectory();
      }
    }

    // iOS va boshqa platformalar uchun ilova hujjatlar papkasi.
    return getApplicationDocumentsDirectory();
  }

  /// Agar biror sababdan backend `outputFormat`ni qaytarmasa (masalan
  /// eski API versiyasi bilan ishlayotgan bo'lsa), original fayl
  /// kengaytmasiga tayanadigan xavfsiz zaxira (fallback) usuli.
  String _fallbackExtension(String originalName) {
    return originalName.contains('.') ? originalName.split('.').last : 'docx';
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
