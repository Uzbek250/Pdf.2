import 'package:flutter/material.dart';

/// Ilova ichidagi UI tili (interfeys tili — bu tarjima maqsad tilidan
/// ALOHIDA narsa: bu yerda "ilova qaysi tilda ko'rinadi" belgilanadi).
enum AppLocale { uz, ru, en }

extension AppLocaleX on AppLocale {
  String get code {
    switch (this) {
      case AppLocale.uz:
        return 'uz';
      case AppLocale.ru:
        return 'ru';
      case AppLocale.en:
        return 'en';
    }
  }

  String get nativeName {
    switch (this) {
      case AppLocale.uz:
        return "O'zbekcha";
      case AppLocale.ru:
        return 'Русский';
      case AppLocale.en:
        return 'English';
    }
  }

  static AppLocale fromCode(String? code) {
    switch (code) {
      case 'ru':
        return AppLocale.ru;
      case 'en':
        return AppLocale.en;
      case 'uz':
      default:
        return AppLocale.uz;
    }
  }
}

/// Ilova bo'ylab ishlatiladigan barcha matnlarni saqlovchi oddiy,
/// yengil (lightweight) i18n klassi.
///
/// `flutter_localizations` + `.arb` generatsiyasi o'rniga qo'lda yozilgan
/// lug'at ishlatilgan — sababi: loyiha faqat telefondan (laptopsiz) build
/// qilinadi, shu bilan bir qatorda kod generatsiyasi (`flutter gen-l10n`)
/// qo'shimcha CI bosqichi va potentsial xatolik manbai bo'ladi. Oddiy Map
/// yechimi CodeMagic/Railway kabi CI muhitlarida hech qanday qo'shimcha
/// bosqichsiz ishlaydi.
class AppStrings {
  final AppLocale locale;
  const AppStrings(this.locale);

  static AppStrings of(BuildContext context) {
    return AppLocaleScope.of(context);
  }

  String _t(Map<AppLocale, String> map) => map[locale] ?? map[AppLocale.en]!;

  String get appTitle => _t({
        AppLocale.uz: 'Hujjat Tarjimon',
        AppLocale.ru: 'Переводчик документов',
        AppLocale.en: 'Document Translator',
      });

  String get homeTitle => _t({
        AppLocale.uz: 'Hujjatni tarjima qiling',
        AppLocale.ru: 'Переведите документ',
        AppLocale.en: 'Translate a document',
      });

  String get homeSubtitle => _t({
        AppLocale.uz: 'PDF yoki DOCX faylni tanlang — formatini saqlab '
            'tarjima qilamiz.',
        AppLocale.ru: 'Выберите файл PDF или DOCX — переведём с '
            'сохранением формата.',
        AppLocale.en: 'Choose a PDF or DOCX file — we\'ll translate it '
            'while preserving formatting.',
      });

  String get pickFileButton => _t({
        AppLocale.uz: 'Fayl tanlash',
        AppLocale.ru: 'Выбрать файл',
        AppLocale.en: 'Choose file',
      });

  String get targetLanguageLabel => _t({
        AppLocale.uz: 'Tarjima tili',
        AppLocale.ru: 'Язык перевода',
        AppLocale.en: 'Target language',
      });

  String get startTranslationButton => _t({
        AppLocale.uz: 'Tarjima qilish',
        AppLocale.ru: 'Перевести',
        AppLocale.en: 'Translate',
      });

  String get noFileSelected => _t({
        AppLocale.uz: 'Fayl tanlanmagan',
        AppLocale.ru: 'Файл не выбран',
        AppLocale.en: 'No file selected',
      });

  String get settingsTitle => _t({
        AppLocale.uz: 'Sozlamalar',
        AppLocale.ru: 'Настройки',
        AppLocale.en: 'Settings',
      });

  String get interfaceLanguage => _t({
        AppLocale.uz: 'Ilova tili',
        AppLocale.ru: 'Язык интерфейса',
        AppLocale.en: 'Interface language',
      });

  String get statusPending => _t({
        AppLocale.uz: 'Navbatda...',
        AppLocale.ru: 'В очереди...',
        AppLocale.en: 'Queued...',
      });

  String get statusDetectingLanguage => _t({
        AppLocale.uz: 'Til aniqlanmoqda...',
        AppLocale.ru: 'Определение языка...',
        AppLocale.en: 'Detecting language...',
      });

  String get statusConvertingToDocx => _t({
        AppLocale.uz: 'DOCX formatga o\'girilmoqda...',
        AppLocale.ru: 'Конвертация в DOCX...',
        AppLocale.en: 'Converting to DOCX...',
      });

  String get statusOcr => _t({
        AppLocale.uz: 'Skaner sahifalar o\'qilmoqda (OCR)...',
        AppLocale.ru: 'Распознавание сканированных страниц (OCR)...',
        AppLocale.en: 'Reading scanned pages (OCR)...',
      });

  String get statusTranslating => _t({
        AppLocale.uz: 'Tarjima qilinmoqda...',
        AppLocale.ru: 'Перевод...',
        AppLocale.en: 'Translating...',
      });

  String get statusConvertingToPdf => _t({
        AppLocale.uz: 'PDF formatga o\'girilmoqda...',
        AppLocale.ru: 'Конвертация в PDF...',
        AppLocale.en: 'Converting to PDF...',
      });

  String get statusCompleted => _t({
        AppLocale.uz: 'Tayyor!',
        AppLocale.ru: 'Готово!',
        AppLocale.en: 'Completed!',
      });

  String get statusFailed => _t({
        AppLocale.uz: 'Xatolik yuz berdi',
        AppLocale.ru: 'Произошла ошибка',
        AppLocale.en: 'Something went wrong',
      });

  String get statusUploading => _t({
        AppLocale.uz: 'Fayl yuklanmoqda...',
        AppLocale.ru: 'Загрузка файла...',
        AppLocale.en: 'Uploading file...',
      });

  String get downloadButton => _t({
        AppLocale.uz: 'Yuklab olish',
        AppLocale.ru: 'Скачать',
        AppLocale.en: 'Download',
      });

  String get openFileButton => _t({
        AppLocale.uz: 'Faylni ochish',
        AppLocale.ru: 'Открыть файл',
        AppLocale.en: 'Open file',
      });

  String get newTranslationButton => _t({
        AppLocale.uz: 'Yangi tarjima',
        AppLocale.ru: 'Новый перевод',
        AppLocale.en: 'New translation',
      });

  String get retryButton => _t({
        AppLocale.uz: 'Qayta urinish',
        AppLocale.ru: 'Повторить',
        AppLocale.en: 'Retry',
      });

  String get cancelButton => _t({
        AppLocale.uz: 'Bekor qilish',
        AppLocale.ru: 'Отмена',
        AppLocale.en: 'Cancel',
      });

  String get errorTimeout => _t({
        AppLocale.uz: 'Server javob bermadi. Internetni tekshiring.',
        AppLocale.ru: 'Сервер не отвечает. Проверьте интернет.',
        AppLocale.en: 'Server did not respond. Check your connection.',
      });

  String get errorNoConnection => _t({
        AppLocale.uz: 'Internetga ulanish yo\'q.',
        AppLocale.ru: 'Нет подключения к интернету.',
        AppLocale.en: 'No internet connection.',
      });

  String get errorServerDown => _t({
        AppLocale.uz: 'Serverda muammo. Birozdan so\'ng qayta urinib '
            'ko\'ring.',
        AppLocale.ru: 'Проблема на сервере. Попробуйте позже.',
        AppLocale.en: 'Server issue. Please try again shortly.',
      });

  String get errorRateLimited => _t({
        AppLocale.uz: 'So\'rovlar juda ko\'p. Biroz kuting.',
        AppLocale.ru: 'Слишком много запросов. Подождите немного.',
        AppLocale.en: 'Too many requests. Please wait a moment.',
      });

  String get fileTooLargeOrInvalid => _t({
        AppLocale.uz: 'Faqat PDF yoki DOCX fayl tanlang.',
        AppLocale.ru: 'Выберите только файл PDF или DOCX.',
        AppLocale.en: 'Please select a PDF or DOCX file only.',
      });

  String get openFileFailed => _t({
        AppLocale.uz: 'Faylni ochib bo\'lmadi. Fayl ilovasi topilmadi.',
        AppLocale.ru: 'Не удалось открыть файл. Приложение не найдено.',
        AppLocale.en: 'Could not open the file. No app found.',
      });

  /// [ApiErrorType] nomiga qarab tarjima qilingan xabarni qaytaradi.
  ///
  /// `api_service.dart` ichidagi `ApiException.message` interfeys tilidan
  /// bexabar (u faqat o'zbekcha yozilgan), shu sababli UI qatlami xatolik
  /// turini (`errorType.name`) shu metodga uzatib, joriy interfeys tiliga
  /// mos matnni oladi.
  String forErrorType(String errorTypeName) {
    switch (errorTypeName) {
      case 'timeout':
        return errorTimeout;
      case 'noConnection':
        return errorNoConnection;
      case 'serverDown':
        return errorServerDown;
      case 'rateLimited':
        return errorRateLimited;
      default:
        return errorServerDown;
    }
  }
}

/// [AppStrings]ni butun widget daraxti bo'ylab uzatuvchi InheritedWidget.
class AppLocaleScope extends InheritedWidget {
  final AppLocale locale;
  final AppStrings strings;

  AppLocaleScope({
    super.key,
    required this.locale,
    required super.child,
  }) : strings = AppStrings(locale);

  static AppStrings of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();
    return scope?.strings ?? const AppStrings(AppLocale.uz);
  }

  @override
  bool updateShouldNotify(AppLocaleScope oldWidget) =>
      oldWidget.locale != locale;
}
