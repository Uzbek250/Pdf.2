import 'package:flutter/material.dart';

/// Ilova ichidagi UI tili (interfeys tili — bu tarjima maqsad tilidan
/// ALOHIDA narsa: bu yerda "ilova qaysi tilda ko'rinadi" belgilanadi).
enum AppLocale { uz, ru, en, tr, ar, kk, tg, zh, es, fr, de, ky }

extension AppLocaleX on AppLocale {
  String get code {
    switch (this) {
      case AppLocale.uz:
        return 'uz';
      case AppLocale.ru:
        return 'ru';
      case AppLocale.en:
        return 'en';
      case AppLocale.tr:
        return 'tr';
      case AppLocale.ar:
        return 'ar';
      case AppLocale.kk:
        return 'kk';
      case AppLocale.tg:
        return 'tg';
      case AppLocale.zh:
        return 'zh';
      case AppLocale.es:
        return 'es';
      case AppLocale.fr:
        return 'fr';
      case AppLocale.de:
        return 'de';
      case AppLocale.ky:
        return 'ky';
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
      case AppLocale.tr:
        return 'Türkçe';
      case AppLocale.ar:
        return 'العربية';
      case AppLocale.kk:
        return 'Қазақша';
      case AppLocale.tg:
        return 'Тоҷикӣ';
      case AppLocale.zh:
        return '中文';
      case AppLocale.es:
        return 'Español';
      case AppLocale.fr:
        return 'Français';
      case AppLocale.de:
        return 'Deutsch';
      case AppLocale.ky:
        return 'Кыргызча';
    }
  }

  static AppLocale fromCode(String? code) {
    switch (code) {
      case 'ru':
        return AppLocale.ru;
      case 'en':
        return AppLocale.en;
      case 'tr':
        return AppLocale.tr;
      case 'ar':
        return AppLocale.ar;
      case 'kk':
        return AppLocale.kk;
      case 'tg':
        return AppLocale.tg;
      case 'zh':
        return AppLocale.zh;
      case 'es':
        return AppLocale.es;
      case 'fr':
        return AppLocale.fr;
      case 'de':
        return AppLocale.de;
      case 'ky':
        return AppLocale.ky;
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

  /// Ilova ochilganda splash ekranida ko'rsatiladigan qisqa salomlashish
  /// so'zi (interfeys tiliga mos, iPhone'ning "Hello" ekraniga o'xshab).
  String get helloGreeting => _t({
        AppLocale.uz: 'Salom',
        AppLocale.ru: 'Привет',
        AppLocale.en: 'Hello',
        AppLocale.tr: 'Merhaba',
        AppLocale.ar: 'مرحبا',
        AppLocale.kk: 'Сәлем',
        AppLocale.tg: 'Салом',
        AppLocale.zh: '你好',
        AppLocale.es: 'Hola',
        AppLocale.fr: 'Bonjour',
        AppLocale.de: 'Hallo',
        AppLocale.ky: 'Салам',
      });

  String get appTitle => _t({
        AppLocale.uz: 'Hujjat Tarjimon',
        AppLocale.ru: 'Переводчик документов',
        AppLocale.en: 'Document Translator',
        AppLocale.tr: 'Belge Çevirmen',
        AppLocale.ar: 'مترجم المستندات',
        AppLocale.kk: 'Құжат аудармашысы',
        AppLocale.tg: 'Тарҷумони ҳуҷҷат',
        AppLocale.zh: '文档翻译',
        AppLocale.es: 'Traductor de documentos',
        AppLocale.fr: 'Traducteur de documents',
        AppLocale.de: 'Dokumentübersetzer',
        AppLocale.ky: 'Документ котормочу',
      });

  String get homeTitle => _t({
        AppLocale.uz: 'Hujjatni tarjima qiling',
        AppLocale.ru: 'Переведите документ',
        AppLocale.en: 'Translate a document',
        AppLocale.tr: 'Bir belge çevirin',
        AppLocale.ar: 'ترجم مستندًا',
        AppLocale.kk: 'Құжатты аударыңыз',
        AppLocale.tg: 'Ҳуҷҷатро тарҷума кунед',
        AppLocale.zh: '翻译文档',
        AppLocale.es: 'Traducir un documento',
        AppLocale.fr: 'Traduire un document',
        AppLocale.de: 'Ein Dokument übersetzen',
        AppLocale.ky: 'Документти которуу',
      });

  String get homeSubtitle => _t({
        AppLocale.uz: 'PDF yoki DOCX faylni tanlang — formatini saqlab '
            'tarjima qilamiz.',
        AppLocale.ru: 'Выберите файл PDF или DOCX — переведём с '
            'сохранением формата.',
        AppLocale.en: 'Choose a PDF or DOCX file — we\'ll translate it '
            'while preserving formatting.',
        AppLocale.tr: 'Bir PDF veya DOCX dosyası seçin — biçimini '
            'koruyarak çeviririz.',
        AppLocale.ar: 'اختر ملف PDF أو DOCX — سنترجمه مع الحفاظ على '
            'التنسيق.',
        AppLocale.kk: 'PDF немесе DOCX файлын таңдаңыз — пішімін сақтай '
            'отырып аударамыз.',
        AppLocale.tg: 'Файли PDF ё DOCX-ро интихоб кунед — мо онро бо '
            'нигоҳ доштани формат тарҷума мекунем.',
        AppLocale.zh: '选择一个 PDF 或 DOCX 文件——我们会在保留格式的同时进行翻译。',
        AppLocale.es: 'Elige un archivo PDF o DOCX; lo traduciremos '
            'conservando el formato.',
        AppLocale.fr: 'Choisissez un fichier PDF ou DOCX — nous le '
            'traduirons en conservant la mise en forme.',
        AppLocale.de: 'Wählen Sie eine PDF- oder DOCX-Datei — wir '
            'übersetzen sie unter Beibehaltung des Formats.',
        AppLocale.ky: 'PDF же DOCX файлын тандаңыз — форматын сактап '
            'которобуз.',
      });

  String get pickFileButton => _t({
        AppLocale.uz: 'Fayl tanlash',
        AppLocale.ru: 'Выбрать файл',
        AppLocale.en: 'Choose file',
        AppLocale.tr: 'Dosya seç',
        AppLocale.ar: 'اختر ملفًا',
        AppLocale.kk: 'Файлды таңдау',
        AppLocale.tg: 'Файлро интихоб кунед',
        AppLocale.zh: '选择文件',
        AppLocale.es: 'Elegir archivo',
        AppLocale.fr: 'Choisir un fichier',
        AppLocale.de: 'Datei auswählen',
        AppLocale.ky: 'Файл тандоо',
      });

  String get targetLanguageLabel => _t({
        AppLocale.uz: 'Tarjima tili',
        AppLocale.ru: 'Язык перевода',
        AppLocale.en: 'Target language',
        AppLocale.tr: 'Hedef dil',
        AppLocale.ar: 'اللغة الهدف',
        AppLocale.kk: 'Мақсатты тіл',
        AppLocale.tg: 'Забони мақсаднок',
        AppLocale.zh: '目标语言',
        AppLocale.es: 'Idioma de destino',
        AppLocale.fr: 'Langue cible',
        AppLocale.de: 'Zielsprache',
        AppLocale.ky: 'Котормо тили',
      });

  String get startTranslationButton => _t({
        AppLocale.uz: 'Tarjima qilish',
        AppLocale.ru: 'Перевести',
        AppLocale.en: 'Translate',
        AppLocale.tr: 'Çevir',
        AppLocale.ar: 'ترجم',
        AppLocale.kk: 'Аудару',
        AppLocale.tg: 'Тарҷума кардан',
        AppLocale.zh: '翻译',
        AppLocale.es: 'Traducir',
        AppLocale.fr: 'Traduire',
        AppLocale.de: 'Übersetzen',
        AppLocale.ky: 'Которуу',
      });

  String get noFileSelected => _t({
        AppLocale.uz: 'Fayl tanlanmagan',
        AppLocale.ru: 'Файл не выбран',
        AppLocale.en: 'No file selected',
        AppLocale.tr: 'Dosya seçilmedi',
        AppLocale.ar: 'لم يتم اختيار ملف',
        AppLocale.kk: 'Файл таңдалмаған',
        AppLocale.tg: 'Файл интихоб нашудааст',
        AppLocale.zh: '未选择文件',
        AppLocale.es: 'Ningún archivo seleccionado',
        AppLocale.fr: 'Aucun fichier sélectionné',
        AppLocale.de: 'Keine Datei ausgewählt',
        AppLocale.ky: 'Файл тандалган жок',
      });

  String get settingsTitle => _t({
        AppLocale.uz: 'Sozlamalar',
        AppLocale.ru: 'Настройки',
        AppLocale.en: 'Settings',
        AppLocale.tr: 'Ayarlar',
        AppLocale.ar: 'الإعدادات',
        AppLocale.kk: 'Параметрлер',
        AppLocale.tg: 'Танзимот',
        AppLocale.zh: '设置',
        AppLocale.es: 'Configuración',
        AppLocale.fr: 'Paramètres',
        AppLocale.de: 'Einstellungen',
        AppLocale.ky: 'Жөндөөлөр',
      });

  String get interfaceLanguage => _t({
        AppLocale.uz: 'Ilova tili',
        AppLocale.ru: 'Язык интерфейса',
        AppLocale.en: 'Interface language',
        AppLocale.tr: 'Arayüz dili',
        AppLocale.ar: 'لغة الواجهة',
        AppLocale.kk: 'Интерфейс тілі',
        AppLocale.tg: 'Забони интерфейс',
        AppLocale.zh: '界面语言',
        AppLocale.es: 'Idioma de la interfaz',
        AppLocale.fr: "Langue de l'interface",
        AppLocale.de: 'Oberflächensprache',
        AppLocale.ky: 'Интерфейс тили',
      });

  String get themeSectionTitle => _t({
        AppLocale.uz: 'Mavzu',
        AppLocale.ru: 'Тема',
        AppLocale.en: 'Theme',
        AppLocale.tr: 'Tema',
        AppLocale.ar: 'المظهر',
        AppLocale.kk: 'Тақырып',
        AppLocale.tg: 'Мавзӯъ',
        AppLocale.zh: '主题',
        AppLocale.es: 'Tema',
        AppLocale.fr: 'Thème',
        AppLocale.de: 'Design',
        AppLocale.ky: 'Тема',
      });

  String get themeProfessional => _t({
        AppLocale.uz: 'Ishonchli',
        AppLocale.ru: 'Надёжная',
        AppLocale.en: 'Trustworthy',
        AppLocale.tr: 'Güvenilir',
        AppLocale.ar: 'موثوق',
        AppLocale.kk: 'Сенімді',
        AppLocale.tg: 'Боэътимод',
        AppLocale.zh: '专业信赖',
        AppLocale.es: 'Confiable',
        AppLocale.fr: 'Fiable',
        AppLocale.de: 'Vertrauenswürdig',
        AppLocale.ky: 'Ишенимдүү',
      });

  String get themeMinimalist => _t({
        AppLocale.uz: 'Minimalist',
        AppLocale.ru: 'Минималистичная',
        AppLocale.en: 'Minimalist',
        AppLocale.tr: 'Minimalist',
        AppLocale.ar: 'بسيط',
        AppLocale.kk: 'Минималистік',
        AppLocale.tg: 'Минималистӣ',
        AppLocale.zh: '简约',
        AppLocale.es: 'Minimalista',
        AppLocale.fr: 'Minimaliste',
        AppLocale.de: 'Minimalistisch',
        AppLocale.ky: 'Минималисттик',
      });

  String get themeVibrant => _t({
        AppLocale.uz: 'Jonli',
        AppLocale.ru: 'Яркая',
        AppLocale.en: 'Vibrant',
        AppLocale.tr: 'Canlı',
        AppLocale.ar: 'نابض بالحياة',
        AppLocale.kk: 'Жанды',
        AppLocale.tg: 'Пурҷило',
        AppLocale.zh: '活力',
        AppLocale.es: 'Vibrante',
        AppLocale.fr: 'Vif',
        AppLocale.de: 'Lebendig',
        AppLocale.ky: 'Жандуу',
      });

  String get statusPending => _t({
        AppLocale.uz: 'Navbatda...',
        AppLocale.ru: 'В очереди...',
        AppLocale.en: 'Queued...',
        AppLocale.tr: 'Sırada...',
        AppLocale.ar: 'في الانتظار...',
        AppLocale.kk: 'Кезекте...',
        AppLocale.tg: 'Дар навбат...',
        AppLocale.zh: '排队中…',
        AppLocale.es: 'En cola...',
        AppLocale.fr: "En file d'attente...",
        AppLocale.de: 'In der Warteschlange...',
        AppLocale.ky: 'Кезекте...',
      });

  String get statusDetectingLanguage => _t({
        AppLocale.uz: 'Til aniqlanmoqda...',
        AppLocale.ru: 'Определение языка...',
        AppLocale.en: 'Detecting language...',
        AppLocale.tr: 'Dil algılanıyor...',
        AppLocale.ar: 'يتم اكتشاف اللغة...',
        AppLocale.kk: 'Тіл анықталуда...',
        AppLocale.tg: 'Забон муайян карда мешавад...',
        AppLocale.zh: '正在检测语言…',
        AppLocale.es: 'Detectando idioma...',
        AppLocale.fr: 'Détection de la langue...',
        AppLocale.de: 'Sprache wird erkannt...',
        AppLocale.ky: 'Тил аныкталууда...',
      });

  String get statusConvertingToDocx => _t({
        AppLocale.uz: 'DOCX formatga o\'girilmoqda...',
        AppLocale.ru: 'Конвертация в DOCX...',
        AppLocale.en: 'Converting to DOCX...',
        AppLocale.tr: "DOCX'e dönüştürülüyor...",
        AppLocale.ar: 'يتم التحويل إلى DOCX...',
        AppLocale.kk: 'DOCX форматына түрлендірілуде...',
        AppLocale.tg: 'Ба DOCX табдил дода мешавад...',
        AppLocale.zh: '正在转换为 DOCX…',
        AppLocale.es: 'Convirtiendo a DOCX...',
        AppLocale.fr: 'Conversion en DOCX...',
        AppLocale.de: 'Wird in DOCX umgewandelt...',
        AppLocale.ky: 'DOCX форматына айландырылууда...',
      });

  String get statusOcr => _t({
        AppLocale.uz: 'Skaner sahifalar o\'qilmoqda (OCR)...',
        AppLocale.ru: 'Распознавание сканированных страниц (OCR)...',
        AppLocale.en: 'Reading scanned pages (OCR)...',
        AppLocale.tr: 'Taranan sayfalar okunuyor (OCR)...',
        AppLocale.ar: 'تتم قراءة الصفحات الممسوحة ضوئيًا (OCR)...',
        AppLocale.kk: 'Сканерленген беттер оқылуда (OCR)...',
        AppLocale.tg: 'Саҳифаҳои сканшуда хонда мешаванд (OCR)...',
        AppLocale.zh: '正在读取扫描页面（OCR）…',
        AppLocale.es: 'Leyendo páginas escaneadas (OCR)...',
        AppLocale.fr: 'Lecture des pages numérisées (OCR)...',
        AppLocale.de: 'Gescannte Seiten werden gelesen (OCR)...',
        AppLocale.ky: 'Скандалган баттар окулууда (OCR)...',
      });

  String get statusTranslating => _t({
        AppLocale.uz: 'Tarjima qilinmoqda...',
        AppLocale.ru: 'Перевод...',
        AppLocale.en: 'Translating...',
        AppLocale.tr: 'Çevriliyor...',
        AppLocale.ar: 'جارٍ الترجمة...',
        AppLocale.kk: 'Аударылуда...',
        AppLocale.tg: 'Тарҷума карда мешавад...',
        AppLocale.zh: '正在翻译…',
        AppLocale.es: 'Traduciendo...',
        AppLocale.fr: 'Traduction en cours...',
        AppLocale.de: 'Wird übersetzt...',
        AppLocale.ky: 'Которулууда...',
      });

  String get statusConvertingToPdf => _t({
        AppLocale.uz: 'PDF formatga o\'girilmoqda...',
        AppLocale.ru: 'Конвертация в PDF...',
        AppLocale.en: 'Converting to PDF...',
        AppLocale.tr: "PDF'e dönüştürülüyor...",
        AppLocale.ar: 'يتم التحويل إلى PDF...',
        AppLocale.kk: 'PDF форматына түрлендірілуде...',
        AppLocale.tg: 'Ба PDF табдил дода мешавад...',
        AppLocale.zh: '正在转换为 PDF…',
        AppLocale.es: 'Convirtiendo a PDF...',
        AppLocale.fr: 'Conversion en PDF...',
        AppLocale.de: 'Wird in PDF umgewandelt...',
        AppLocale.ky: 'PDF форматына айландырылууда...',
      });

  String get statusCompleted => _t({
        AppLocale.uz: 'Tayyor!',
        AppLocale.ru: 'Готово!',
        AppLocale.en: 'Completed!',
        AppLocale.tr: 'Tamamlandı!',
        AppLocale.ar: 'اكتمل!',
        AppLocale.kk: 'Дайын!',
        AppLocale.tg: 'Тайёр шуд!',
        AppLocale.zh: '完成！',
        AppLocale.es: '¡Completado!',
        AppLocale.fr: 'Terminé !',
        AppLocale.de: 'Fertig!',
        AppLocale.ky: 'Даяр!',
      });

  /// Original fayl PDF bo'lgan, lekin natija DOCX formatida tayyorlangan
  /// hollarda foydalanuvchiga ko'rsatiladigan tushuntirish xabari.
  String get pdfConvertedToDocxNotice => _t({
        AppLocale.uz: 'Original fayl PDF edi. Formatni yaxshiroq saqlash '
            'uchun natija Word (.docx) formatida tayyorlandi — kerak '
            'bo\'lsa uni istalgan payt PDF sifatida saqlashingiz mumkin.',
        AppLocale.ru: 'Исходный файл был PDF. Для лучшего сохранения '
            'формата результат подготовлен в формате Word (.docx) — при '
            'необходимости вы можете сохранить его как PDF в любое время.',
        AppLocale.en: 'The original file was a PDF. To better preserve '
            'formatting, the result was prepared as a Word (.docx) file '
            '— you can save it as PDF anytime if needed.',
        AppLocale.tr: 'Orijinal dosya PDF idi. Biçimlendirmeyi daha iyi '
            'korumak için sonuç Word (.docx) biçiminde hazırlandı — '
            'gerekirse istediğiniz zaman PDF olarak kaydedebilirsiniz.',
        AppLocale.ar: 'كان الملف الأصلي بصيغة PDF. للحفاظ على التنسيق '
            'بشكل أفضل، تم إعداد النتيجة بصيغة Word (.docx) — يمكنك '
            'حفظها كملف PDF في أي وقت إذا لزم الأمر.',
        AppLocale.kk: 'Бастапқы файл PDF болды. Пішімді жақсырақ сақтау '
            'үшін нәтиже Word (.docx) форматында дайындалды — қажет '
            'болса, оны кез келген уақытта PDF ретінде сақтай аласыз.',
        AppLocale.tg: 'Файли аслӣ PDF буд. Барои беҳтар нигоҳ доштани '
            'формат, натиҷа дар формати Word (.docx) омода шуд — дар '
            'сурати зарурат метавонед онро ҳамчун PDF захира кунед.',
        AppLocale.zh: '原始文件是 PDF。为了更好地保留格式，结果已准备为 '
            'Word (.docx) 文件——如有需要，您可以随时将其另存为 PDF。',
        AppLocale.es: 'El archivo original era un PDF. Para conservar '
            'mejor el formato, el resultado se preparó como un archivo '
            'Word (.docx) — puede guardarlo como PDF en cualquier '
            'momento si lo necesita.',
        AppLocale.fr: 'Le fichier original était un PDF. Pour mieux '
            'préserver la mise en forme, le résultat a été préparé au '
            'format Word (.docx) — vous pouvez l\'enregistrer en PDF à '
            'tout moment si nécessaire.',
        AppLocale.de: 'Die Originaldatei war ein PDF. Um die '
            'Formatierung besser zu erhalten, wurde das Ergebnis als '
            'Word-Datei (.docx) vorbereitet — Sie können sie bei Bedarf '
            'jederzeit als PDF speichern.',
        AppLocale.ky: 'Баштапкы файл PDF болчу. Форматты жакшыраак '
            'сактоо үчүн натыйжа Word (.docx) форматында даярдалды — '
            'керек болсо аны каалаган убакта PDF катары сактай аласыз.',
      });

  String get statusFailed => _t({
        AppLocale.uz: 'Xatolik yuz berdi',
        AppLocale.ru: 'Произошла ошибка',
        AppLocale.en: 'Something went wrong',
        AppLocale.tr: 'Bir şeyler ters gitti',
        AppLocale.ar: 'حدث خطأ ما',
        AppLocale.kk: 'Бірдеңе дұрыс болмады',
        AppLocale.tg: 'Хатогӣ рух дод',
        AppLocale.zh: '出错了',
        AppLocale.es: 'Algo salió mal',
        AppLocale.fr: "Une erreur s'est produite",
        AppLocale.de: 'Etwas ist schiefgelaufen',
        AppLocale.ky: 'Ката кетти',
      });

  String get statusUploading => _t({
        AppLocale.uz: 'Fayl yuklanmoqda...',
        AppLocale.ru: 'Загрузка файла...',
        AppLocale.en: 'Uploading file...',
        AppLocale.tr: 'Dosya yükleniyor...',
        AppLocale.ar: 'يتم تحميل الملف...',
        AppLocale.kk: 'Файл жүктелуде...',
        AppLocale.tg: 'Файл бор карда мешавад...',
        AppLocale.zh: '正在上传文件…',
        AppLocale.es: 'Subiendo archivo...',
        AppLocale.fr: 'Téléversement du fichier...',
        AppLocale.de: 'Datei wird hochgeladen...',
        AppLocale.ky: 'Файл жүктөлүүдө...',
      });

  String get downloadButton => _t({
        AppLocale.uz: 'Yuklab olish',
        AppLocale.ru: 'Скачать',
        AppLocale.en: 'Download',
        AppLocale.tr: 'İndir',
        AppLocale.ar: 'تنزيل',
        AppLocale.kk: 'Жүктеп алу',
        AppLocale.tg: 'Боргирӣ',
        AppLocale.zh: '下载',
        AppLocale.es: 'Descargar',
        AppLocale.fr: 'Télécharger',
        AppLocale.de: 'Herunterladen',
        AppLocale.ky: 'Жүктөп алуу',
      });

  String get openFileButton => _t({
        AppLocale.uz: 'Faylni ochish',
        AppLocale.ru: 'Открыть файл',
        AppLocale.en: 'Open file',
        AppLocale.tr: 'Dosyayı aç',
        AppLocale.ar: 'فتح الملف',
        AppLocale.kk: 'Файлды ашу',
        AppLocale.tg: 'Файлро кушодан',
        AppLocale.zh: '打开文件',
        AppLocale.es: 'Abrir archivo',
        AppLocale.fr: 'Ouvrir le fichier',
        AppLocale.de: 'Datei öffnen',
        AppLocale.ky: 'Файлды ачуу',
      });

  String get newTranslationButton => _t({
        AppLocale.uz: 'Yangi tarjima',
        AppLocale.ru: 'Новый перевод',
        AppLocale.en: 'New translation',
        AppLocale.tr: 'Yeni çeviri',
        AppLocale.ar: 'ترجمة جديدة',
        AppLocale.kk: 'Жаңа аударма',
        AppLocale.tg: 'Тарҷумаи нав',
        AppLocale.zh: '新的翻译',
        AppLocale.es: 'Nueva traducción',
        AppLocale.fr: 'Nouvelle traduction',
        AppLocale.de: 'Neue Übersetzung',
        AppLocale.ky: 'Жаңы котормо',
      });

  String get retryButton => _t({
        AppLocale.uz: 'Qayta urinish',
        AppLocale.ru: 'Повторить',
        AppLocale.en: 'Retry',
        AppLocale.tr: 'Tekrar dene',
        AppLocale.ar: 'أعد المحاولة',
        AppLocale.kk: 'Қайталау',
        AppLocale.tg: 'Аз нав кӯшиш кунед',
        AppLocale.zh: '重试',
        AppLocale.es: 'Reintentar',
        AppLocale.fr: 'Réessayer',
        AppLocale.de: 'Erneut versuchen',
        AppLocale.ky: 'Кайра аракет кылуу',
      });

  String get cancelButton => _t({
        AppLocale.uz: 'Bekor qilish',
        AppLocale.ru: 'Отмена',
        AppLocale.en: 'Cancel',
        AppLocale.tr: 'İptal',
        AppLocale.ar: 'إلغاء',
        AppLocale.kk: 'Бас тарту',
        AppLocale.tg: 'Бекор кардан',
        AppLocale.zh: '取消',
        AppLocale.es: 'Cancelar',
        AppLocale.fr: 'Annuler',
        AppLocale.de: 'Abbrechen',
        AppLocale.ky: 'Жокко чыгаруу',
      });

  String get errorTimeout => _t({
        AppLocale.uz: 'Server javob bermadi. Internetni tekshiring.',
        AppLocale.ru: 'Сервер не отвечает. Проверьте интернет.',
        AppLocale.en: 'Server did not respond. Check your connection.',
        AppLocale.tr: 'Sunucu yanıt vermedi. Bağlantınızı kontrol edin.',
        AppLocale.ar: 'لم يستجب الخادم. تحقق من اتصالك.',
        AppLocale.kk: 'Сервер жауап бермеді. Интернетті тексеріңіз.',
        AppLocale.tg: 'Сервер ҷавоб надод. Пайвастшавиро санҷед.',
        AppLocale.zh: '服务器无响应，请检查网络连接。',
        AppLocale.es: 'El servidor no respondió. Verifica tu conexión.',
        AppLocale.fr: "Le serveur n'a pas répondu. Vérifiez votre connexion.",
        AppLocale.de: 'Der Server hat nicht geantwortet. Überprüfen Sie '
            'Ihre Verbindung.',
        AppLocale.ky: 'Сервер жооп берген жок. Интернетти текшериңиз.',
      });

  String get errorNoConnection => _t({
        AppLocale.uz: 'Internetga ulanish yo\'q.',
        AppLocale.ru: 'Нет подключения к интернету.',
        AppLocale.en: 'No internet connection.',
        AppLocale.tr: 'İnternet bağlantısı yok.',
        AppLocale.ar: 'لا يوجد اتصال بالإنترنت.',
        AppLocale.kk: 'Интернет байланысы жоқ.',
        AppLocale.tg: 'Пайвастшавӣ ба интернет нест.',
        AppLocale.zh: '没有网络连接。',
        AppLocale.es: 'Sin conexión a internet.',
        AppLocale.fr: 'Aucune connexion internet.',
        AppLocale.de: 'Keine Internetverbindung.',
        AppLocale.ky: 'Интернет байланышы жок.',
      });

  String get errorServerDown => _t({
        AppLocale.uz: 'Serverda muammo. Birozdan so\'ng qayta urinib '
            'ko\'ring.',
        AppLocale.ru: 'Проблема на сервере. Попробуйте позже.',
        AppLocale.en: 'Server issue. Please try again shortly.',
        AppLocale.tr: 'Sunucu sorunu. Lütfen kısa süre sonra tekrar deneyin.',
        AppLocale.ar: 'مشكلة في الخادم. حاول مرة أخرى قريبًا.',
        AppLocale.kk: 'Серверде ақау. Жақында қайта көріңіз.',
        AppLocale.tg: 'Мушкилии сервер. Лутфан баъдтар аз нав кӯшиш кунед.',
        AppLocale.zh: '服务器出现问题，请稍后重试。',
        AppLocale.es: 'Problema en el servidor. Inténtalo de nuevo en '
            'breve.',
        AppLocale.fr: 'Problème serveur. Réessayez dans un instant.',
        AppLocale.de: 'Serverproblem. Bitte versuchen Sie es in Kürze '
            'erneut.',
        AppLocale.ky: 'Сервердик ката. Бир аздан кийин кайра аракет '
            'кылыңыз.',
      });

  String get errorRateLimited => _t({
        AppLocale.uz: 'So\'rovlar juda ko\'p. Biroz kuting.',
        AppLocale.ru: 'Слишком много запросов. Подождите немного.',
        AppLocale.en: 'Too many requests. Please wait a moment.',
        AppLocale.tr: 'Çok fazla istek. Lütfen biraz bekleyin.',
        AppLocale.ar: 'طلبات كثيرة جدًا. يرجى الانتظار قليلاً.',
        AppLocale.kk: 'Тым көп сұраныс. Сәл күтіңіз.',
        AppLocale.tg: 'Дархостҳои зиёд. Лутфан каме сабр кунед.',
        AppLocale.zh: '请求过多，请稍候。',
        AppLocale.es: 'Demasiadas solicitudes. Espera un momento.',
        AppLocale.fr: 'Trop de requêtes. Veuillez patienter.',
        AppLocale.de: 'Zu viele Anfragen. Bitte warten Sie einen Moment.',
        AppLocale.ky: 'Өтө көп сурам. Бир аз күтө туруңуз.',
      });

  String get fileTooLargeOrInvalid => _t({
        AppLocale.uz: 'Faqat PDF yoki DOCX fayl tanlang.',
        AppLocale.ru: 'Выберите только файл PDF или DOCX.',
        AppLocale.en: 'Please select a PDF or DOCX file only.',
        AppLocale.tr: 'Lütfen yalnızca PDF veya DOCX dosyası seçin.',
        AppLocale.ar: 'يرجى اختيار ملف PDF أو DOCX فقط.',
        AppLocale.kk: 'Тек PDF немесе DOCX файлын таңдаңыз.',
        AppLocale.tg: 'Лутфан танҳо файли PDF ё DOCX-ро интихоб кунед.',
        AppLocale.zh: '请只选择 PDF 或 DOCX 文件。',
        AppLocale.es: 'Selecciona solo un archivo PDF o DOCX.',
        AppLocale.fr: 'Veuillez sélectionner uniquement un fichier PDF ou '
            'DOCX.',
        AppLocale.de: 'Bitte wählen Sie nur eine PDF- oder DOCX-Datei aus.',
        AppLocale.ky: 'Сураныч, PDF же DOCX файлын гана тандаңыз.',
      });

  String get openFileFailed => _t({
        AppLocale.uz: 'Faylni ochib bo\'lmadi. Fayl ilovasi topilmadi.',
        AppLocale.ru: 'Не удалось открыть файл. Приложение не найдено.',
        AppLocale.en: 'Could not open the file. No app found.',
        AppLocale.tr: 'Dosya açılamadı. Uygulama bulunamadı.',
        AppLocale.ar: 'تعذر فتح الملف. لم يتم العثور على تطبيق.',
        AppLocale.kk: 'Файлды ашу мүмкін болмады. Қолданба табылмады.',
        AppLocale.tg: 'Кушодани файл имконнопазир аст. Замима ёфт нашуд.',
        AppLocale.zh: '无法打开文件，未找到可用应用。',
        AppLocale.es: 'No se pudo abrir el archivo. No se encontró '
            'ninguna app.',
        AppLocale.fr: 'Impossible d\'ouvrir le fichier. Aucune application '
            'trouvée.',
        AppLocale.de: 'Datei konnte nicht geöffnet werden. Keine App '
            'gefunden.',
        AppLocale.ky: 'Файлды ачуу мүмкүн болгон жок. Колдонмо табылган '
            'жок.',
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
