# Hujjat Tarjimon — Flutter frontend

PDF va DOCX fayllarni original formatini saqlab tarjima qiluvchi mobil ilova.
Backend: Railway'da ishlayotgan FastAPI (Gemini asosida).

## Arxitektura

```
lib/
├── main.dart                      — kirish nuqtasi, ProviderScope + tema
├── app/
│   ├── theme.dart                 — Material Design 3 tema
│   ├── router.dart                — named routes
│   └── app_strings.dart           — UZ/RU/EN matnlar (paketsiz i18n)
├── models/
│   ├── language_model.dart        — /api/languages javobi
│   └── translation_task_state.dart — progress + task state
├── services/
│   ├── api_service.dart           — Dio: upload, SSE, download, tillar
│   └── storage_service.dart       — SharedPreferences wrapper
├── providers/
│   └── translation_provider.dart  — Riverpod: barcha state shu yerda
└── features/
    ├── home/                      — fayl tanlash + til tanlash ekrani
    ├── translate/                 — progress + yuklab olish ekrani
    └── settings/                  — interfeys tilini o'zgartirish
```

## Muhim texnik qarorlar

1. **Til eslab qolish (MAJBURIY TALAB)**: `SelectedLanguageNotifier`
   `StateNotifier` ishga tushganda `StorageService.getLastTargetLang()`ni
   avtomatik o'qiydi. Foydalanuvchi til tanlaganda `selectLanguage()`
   darhol `SharedPreferences`ga yozadi. Ikkinchi marta ilovani ochganda
   til qayta so'ralmaydi.

2. **SSE progress**: `ApiService.watchProgress()` Dio'ning
   `ResponseType.stream` orqali xom baytlarni o'qiydi, `\n\n` bo'yicha
   hodisalarga (event) bo'ladi va `data:` prefiksini tozalab JSON parse
   qiladi. Bitta buzuq paket butun oqimni to'xtatmaydi. `completed` yoki
   `failed` kelganda stream avtomatik yopiladi.

3. **Xatolik boshqaruvi**: `ApiService._mapError()` barcha Dio
   xatoliklarini (`timeout`, `connectionError`, `429`, `5xx`, ...)
   `ApiException` + `ApiErrorType` enumiga aylantiradi. UI qatlami
   `AppStrings.forErrorType()` orqali joriy interfeys tilida ko'rsatadi.

4. **i18n paketsiz**: `flutter gen-l10n` kod generatsiyasi o'rniga oddiy
   `Map<AppLocale, String>` lug'ati ishlatilgan — Bekning ish oqimi
   (telefon + CI/CD, laptopsiz) uchun qo'shimcha build bosqichini oldini
   oladi.

5. **Provider-agnostic state**: `TranslationTaskNotifier` butun
   upload→progress→download hayot siklini boshqaradi, UI faqat
   `ref.watch(translationTaskProvider)` orqali kuzatadi.

## O'rnatish (GitHub → CodeMagic workflow)

Bu loyiha to'liq telefondan (laptopsiz) ishlash uchun mo'ljallangan:

1. Loyihani GitHub repo'ga push qiling.
2. `codemagic.yaml` allaqachon tayyor — CodeMagic'da yangi ilova
   qo'shganda avtomatik topiladi.
3. CodeMagic UI'da **Environment variables** bo'limiga `API_BASE_URL`
   ni Railway backend manzilingiz bilan qo'shing (yoki `codemagic.yaml`
   ichidagi `vars:` qismini to'g'ridan-to'g'ri tahrirlang).
4. Build ishga tushiring — natijada `.apk` va `.aab` fayllar chiqadi.

## API bazaviy manzilini o'zgartirish

`lib/services/api_service.dart`dagi `_defaultBaseUrl`:

```dart
static const String _defaultBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://your-app.up.railway.app',
);
```

Build vaqtida quyidagicha almashtiriladi:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://siz-manzil.up.railway.app
```

`codemagic.yaml` bu qadamni avtomatik bajaradi (`$API_BASE_URL`
environment variable orqali).

## Backend endpoint moslashuvi

| Endpoint | Flutter metodi |
|---|---|
| `POST /api/translate` | `ApiService.uploadFile()` |
| `GET /api/progress/{task_id}` (SSE) | `ApiService.watchProgress()` |
| `GET /api/download/{task_id}` | `ApiService.downloadFile()` |
| `GET /api/languages` | `ApiService.getLanguages()` |
| `POST /api/detect-lang` | `ApiService.detectLanguage()` |

## Android ruxsatlar

`AndroidManifest.xml`da:
- `INTERNET` — backend bilan aloqa.
- `READ/WRITE_EXTERNAL_STORAGE` (faqat eski Android versiyalar uchun,
  `maxSdkVersion` bilan cheklangan — yangi versiyalarda scoped storage
  ishlatiladi, qo'shimcha ruxsat kerak emas).
- `FileProvider` + `<queries>` — `open_file` paketi tarjima qilingan
  faylni boshqa ilovalarda (Google Docs, Adobe Reader va h.k.) ochishi
  uchun.

## Nima uchun bu paketlar?

- **Riverpod** (`StateNotifier`) — Provider'lar orasida aniq
  bog'liqliklar (`ref.watch`) va testlash qulayligi uchun `Bloc`/`GetX`
  o'rniga tanlandi.
- **Dio** — interceptor, `FormData` (multipart upload), `ResponseType.stream`
  (SSE) va `download()` (progress bilan) barchasi bitta paketda.
- **percent_indicator** — `CircularPercentIndicator` progress ko'rsatish
  uchun animatsiyali, minimal konfiguratsiya bilan.
