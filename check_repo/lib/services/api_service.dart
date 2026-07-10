import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../models/language_model.dart';
import '../models/translation_task_state.dart';

/// Backend bilan bog'liq barcha xatoliklarni birlashtiruvchi umumiy klass.
///
/// UI qatlami bu klass orqali xatolik turini aniqlab, foydalanuvchiga mos
/// xabar ko'rsatishi mumkin (masalan timeout uchun "Internetni tekshiring",
/// rateLimited uchun "Biroz kutib qayta urinib ko'ring").
enum ApiErrorType {
  timeout,
  noConnection,
  serverDown,
  rateLimited,
  badRequest,
  notFound,
  unknown,
}

class ApiException implements Exception {
  final ApiErrorType type;
  final String message;
  final int? statusCode;

  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ApiException(${type.name}): $message';
}

/// Til aniqlash natijasi.
class DetectLangResult {
  final String lang;
  final double confidence;

  const DetectLangResult({required this.lang, required this.confidence});

  factory DetectLangResult.fromJson(Map<String, dynamic> json) {
    return DetectLangResult(
      lang: json['lang'] as String? ?? json['language_code'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Fayl yuklash natijasi (`/api/translate` javobi).
class TranslateUploadResult {
  final String taskId;
  final String status;

  const TranslateUploadResult({required this.taskId, required this.status});

  factory TranslateUploadResult.fromJson(Map<String, dynamic> json) {
    return TranslateUploadResult(
      taskId: json['task_id'] as String,
      status: json['status'] as String? ?? 'processing',
    );
  }
}

/// Backend bilan barcha tarmoq muloqotini boshqaruvchi markaziy xizmat.
///
/// Dio HTTP klienti + logging interceptor + xatoliklarni [ApiException]ga
/// aylantiruvchi markazlashgan error-handling bilan.
class ApiService {
  /// Railway'da ishlayotgan backend manzili.
  ///
  /// Productionda buni `--dart-define=API_BASE_URL=...` orqali build
  /// vaqtida almashtirish mumkin (masalan CodeMagic CI/CD sozlamalarida).
  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://pdf-production-b2cd.up.railway.app',
  );

  final Dio _dio;
  final String baseUrl;

  ApiService({String? baseUrl, Dio? dio})
      : baseUrl = baseUrl ?? _defaultBaseUrl,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? _defaultBaseUrl,
                connectTimeout: const Duration(seconds: 20),
                // Katta fayllar uchun uzoqroq yuklash vaqti
                sendTimeout: const Duration(minutes: 5),
                receiveTimeout: const Duration(seconds: 30),
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _log(
            '➡️  ${options.method} ${options.uri}'
            '${options.data is FormData ? ' (multipart)' : ''}',
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _log(
            '✅ ${response.statusCode} ${response.requestOptions.uri}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          _log(
            '❌ ${error.requestOptions.method} ${error.requestOptions.uri} '
            '-> ${error.type} (${error.response?.statusCode})',
          );
          return handler.next(error);
        },
      ),
    );
  }

  void _log(String message) {
    // ignore: avoid_print
    assert(() {
      print('[ApiService] $message');
      return true;
    }());
  }

  /// Dio xatoligini foydalanuvchiga tushunarli [ApiException]ga aylantiradi.
  ApiException _mapError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          type: ApiErrorType.timeout,
          message:
              'Server javob berish vaqti tugadi. Internet aloqangizni '
              'tekshirib, qayta urinib ko\'ring.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          type: ApiErrorType.noConnection,
          message:
              'Serverga ulanib bo\'lmadi. Internet aloqangizni tekshiring.',
        );
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 429) {
          return const ApiException(
            type: ApiErrorType.rateLimited,
            message:
                'So\'rovlar soni limitiga yetdingiz. Iltimos, biroz kuting.',
            statusCode: 429,
          );
        }
        if (code == 404) {
          return ApiException(
            type: ApiErrorType.notFound,
            message: 'So\'ralgan resurs topilmadi.',
            statusCode: code,
          );
        }
        if (code != null && code >= 500) {
          return ApiException(
            type: ApiErrorType.serverDown,
            message: 'Serverda vaqtinchalik muammo yuz berdi (kod: $code).',
            statusCode: code,
          );
        }
        final detail = _extractDetail(e.response?.data);
        return ApiException(
          type: ApiErrorType.badRequest,
          message: detail ?? 'So\'rov noto\'g\'ri (kod: $code).',
          statusCode: code,
        );
      case DioExceptionType.cancel:
        return const ApiException(
          type: ApiErrorType.unknown,
          message: 'So\'rov bekor qilindi.',
        );
      case DioExceptionType.badCertificate:
      // ignore: unreachable_switch_default (kelajakdagi Dio versiyalarida
      // yangi enum qiymatlari qo'shilishi mumkin — masalan `transformTimeout`
      // Dio 5.10'da paydo bo'ldi. `default` case shu enum'lar uchun ham
      // ishlaydi va yangi Dio versiyasi build'ni buzmasligini kafolatlaydi.
      default:
        return ApiException(
          type: ApiErrorType.unknown,
          message: e.message ?? 'Noma\'lum xatolik yuz berdi.',
        );
    }
  }

  String? _extractDetail(dynamic data) {
    if (data is Map && data['detail'] != null) {
      return data['detail'].toString();
    }
    return null;
  }

  // ------------------------------------------------------------------ //
  // POST /api/translate
  // ------------------------------------------------------------------ //

  /// Fayl (PDF yoki DOCX) va maqsad tilni serverga yuboradi, tarjima
  /// vazifasini navbatga qo'yadi.
  ///
  /// [onSendProgress] fayl yuklanish foizini (0.0-1.0) kuzatish uchun.
  Future<TranslateUploadResult> uploadFile({
    required File file,
    required String targetLang,
    void Function(int sent, int total)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final formData = FormData.fromMap({
        'target_lang': targetLang,
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post(
        '/api/translate',
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
        options: Options(
          headers: {'Accept': 'application/json'},
        ),
      );

      return TranslateUploadResult.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // ------------------------------------------------------------------ //
  // GET /api/progress/{task_id}  (Server-Sent Events)
  // ------------------------------------------------------------------ //

  /// SSE oqimini ochib, har bir hodisa (event) kelganda
  /// [TranslationProgress] obyektini yuboradigan Stream qaytaradi.
  ///
  /// Stream avtomatik ravishda `completed` yoki `failed` holatida yopiladi.
  /// Ulanish uzilib qolsa, [ApiException] bilan xato (error) yuboriladi —
  /// chaqiruvchi kod buni ushlab qayta ulanishi mumkin.
  Stream<TranslationProgress> watchProgress(String taskId) {
    final controller = StreamController<TranslationProgress>();
    final cancelToken = CancelToken();

    () async {
      try {
        final response = await _dio.get<ResponseBody>(
          '/api/progress/$taskId',
          cancelToken: cancelToken,
          options: Options(
            responseType: ResponseType.stream,
            headers: {'Accept': 'text/event-stream'},
            receiveTimeout: const Duration(minutes: 35),
          ),
        );

        final stream = response.data!.stream;
        final buffer = StringBuffer();

        await for (final chunk in stream) {
          final decoded = utf8.decode(chunk, allowMalformed: true);
          buffer.write(decoded);

          // SSE hodisalari "\n\n" bilan ajratiladi
          while (buffer.toString().contains('\n\n')) {
            final raw = buffer.toString();
            final splitIndex = raw.indexOf('\n\n');
            final rawEvent = raw.substring(0, splitIndex);
            buffer
              ..clear()
              ..write(raw.substring(splitIndex + 2));

            final jsonStr = _extractSseData(rawEvent);
            if (jsonStr == null || jsonStr.isEmpty) continue;

            try {
              final data = jsonDecode(jsonStr) as Map<String, dynamic>;
              final progress = TranslationProgress.fromJson(data);
              controller.add(progress);
              if (progress.status.isTerminal) {
                await controller.close();
                return;
              }
            } catch (_) {
              // Bitta buzuq JSON paketi butun oqimni to'xtatmasligi kerak
              continue;
            }
          }
        }

        if (!controller.isClosed) {
          await controller.close();
        }
      } on DioException catch (e) {
        if (!controller.isClosed) {
          controller.addError(_mapError(e));
          await controller.close();
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(
            ApiException(
              type: ApiErrorType.unknown,
              message: 'Progressni kuzatishda xatolik: $e',
            ),
          );
          await controller.close();
        }
      }
    }();

    controller.onCancel = () {
      if (!cancelToken.isCancelled) {
        cancelToken.cancel('Stream tinglovchisi bekor qildi.');
      }
    };

    return controller.stream;
  }

  String? _extractSseData(String rawEvent) {
    final lines = rawEvent.split('\n');
    final dataLines = lines
        .where((l) => l.startsWith('data:'))
        .map((l) => l.substring(5).trim());
    if (dataLines.isEmpty) return null;
    return dataLines.join('\n');
  }

  // ------------------------------------------------------------------ //
  // GET /api/download/{task_id}
  // ------------------------------------------------------------------ //

  /// Tayyor faylni berilgan lokal yo'lga yuklab saqlaydi.
  ///
  /// [savePath] to'liq fayl yo'li bo'lishi kerak (papka emas).
  Future<File> downloadFile({
    required String taskId,
    required String savePath,
    void Function(int received, int total)? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.download(
        '/api/download/$taskId',
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
        options: Options(receiveTimeout: const Duration(minutes: 5)),
      );
      return File(savePath);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // ------------------------------------------------------------------ //
  // GET /api/languages
  // ------------------------------------------------------------------ //

  Future<List<LanguageModel>> getLanguages() async {
    try {
      final response = await _dio.get('/api/languages');
      final list = response.data as List<dynamic>;
      return list
          .map((e) => LanguageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // ------------------------------------------------------------------ //
  // POST /api/detect-lang
  // ------------------------------------------------------------------ //

  Future<DetectLangResult> detectLanguage(String text) async {
    try {
      final response = await _dio.post(
        '/api/detect-lang',
        data: {'text': text},
      );
      return DetectLangResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  void dispose() {
    _dio.close(force: true);
  }
}
