/// Backend `/api/languages` javobidagi bitta tilni ifodalovchi model.
class LanguageModel {
  /// ISO 639-1 kod, masalan "uz".
  final String code;

  /// Ingliz tilidagi nomi, masalan "Uzbek".
  final String nameEn;

  /// Tilning o'z tilidagi nomi, masalan "O'zbekcha".
  final String nameNative;

  const LanguageModel({
    required this.code,
    required this.nameEn,
    required this.nameNative,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      code: json['code'] as String,
      nameEn: json['name_en'] as String? ?? '',
      nameNative: json['name_native'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name_en': nameEn,
        'name_native': nameNative,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LanguageModel && other.code == code);

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'LanguageModel(code: $code, nameNative: $nameNative)';
}
