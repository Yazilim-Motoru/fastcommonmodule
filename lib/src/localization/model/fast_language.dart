import '../../common/model/fast_model.dart';

/// Model for language configuration with support for runtime management.
class FastLanguage extends FastModel {
  /// Language code (e.g., 'tr', 'en', 'fr').
  final String code;

  /// Display name in English (e.g., 'Turkish', 'English').
  final String name;

  /// Native name (e.g., 'Türkçe', 'English').
  final String nativeName;

  /// Whether this language is right-to-left.
  final bool isRTL;

  /// Flag icon URL or asset path (optional).
  final String? flagIcon;

  /// Creates a [FastLanguage] instance.
  const FastLanguage({
    required String id,
    required this.code,
    required this.name,
    required this.nativeName,
    this.isRTL = false,
    this.flagIcon,
  }) : super(id: id);

  /// Creates a [FastLanguage] from JSON.
  factory FastLanguage.fromJson(Map<String, dynamic> json) {
    return FastLanguage(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      nativeName: json['nativeName'] as String,
      isRTL: json['isRTL'] as bool? ?? false,
      flagIcon: json['flagIcon'] as String?,
    );
  }

  /// Converts this [FastLanguage] to JSON.
  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'nativeName': nativeName,
        'isRTL': isRTL,
        if (flagIcon != null) 'flagIcon': flagIcon,
      };

  /// Creates a copy with updated values.
  FastLanguage copyWith({
    String? id,
    String? code,
    String? name,
    String? nativeName,
    bool? isRTL,
    String? flagIcon,
  }) {
    return FastLanguage(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      nativeName: nativeName ?? this.nativeName,
      isRTL: isRTL ?? this.isRTL,
      flagIcon: flagIcon ?? this.flagIcon,
    );
  }

  @override
  String toString() => 'FastLanguage($code, $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FastLanguage &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  /// Common language constants.
  static const FastLanguage turkish = FastLanguage(
    id: 'tr',
    code: 'tr',
    name: 'Turkish',
    nativeName: 'Türkçe',
  );

  static const FastLanguage english = FastLanguage(
    id: 'en',
    code: 'en',
    name: 'English',
    nativeName: 'English',
  );

  static const FastLanguage arabic = FastLanguage(
    id: 'ar',
    code: 'ar',
    name: 'Arabic',
    nativeName: 'العربية',
    isRTL: true,
  );
}
