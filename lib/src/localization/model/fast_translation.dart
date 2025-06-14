import '../../common/model/fast_model.dart';

/// Model for translation entry with key-value pairs and metadata.
class FastTranslation extends FastModel {
  /// Translation key (e.g., 'welcome_message', 'login_button').
  final String key;

  /// Translated value in target language.
  final String value;

  /// Language code for this translation.
  final String languageCode;

  /// Optional context or category for grouping translations.
  final String? context;

  /// Optional description for translators.
  final String? description;

  /// Whether this translation is pluralized.
  final bool isPlural;

  /// Plural forms (for languages with multiple plural forms).
  final Map<String, String>? pluralForms;

  /// Creates a [FastTranslation] instance.
  const FastTranslation({
    required String id,
    required this.key,
    required this.value,
    required this.languageCode,
    this.context,
    this.description,
    this.isPlural = false,
    this.pluralForms,
  }) : super(id: id);

  /// Creates a [FastTranslation] from JSON.
  factory FastTranslation.fromJson(Map<String, dynamic> json) {
    return FastTranslation(
      id: json['id'] as String,
      key: json['key'] as String,
      value: json['value'] as String,
      languageCode: json['languageCode'] as String,
      context: json['context'] as String?,
      description: json['description'] as String?,
      isPlural: json['isPlural'] as bool? ?? false,
      pluralForms: json['pluralForms'] != null
          ? Map<String, String>.from(json['pluralForms'] as Map)
          : null,
    );
  }

  /// Converts this [FastTranslation] to JSON.
  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'key': key,
        'value': value,
        'languageCode': languageCode,
        if (context != null) 'context': context,
        if (description != null) 'description': description,
        'isPlural': isPlural,
        if (pluralForms != null) 'pluralForms': pluralForms,
      };

  /// Creates a copy with updated values.
  FastTranslation copyWith({
    String? id,
    String? key,
    String? value,
    String? languageCode,
    String? context,
    String? description,
    bool? isPlural,
    Map<String, String>? pluralForms,
  }) {
    return FastTranslation(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
      languageCode: languageCode ?? this.languageCode,
      context: context ?? this.context,
      description: description ?? this.description,
      isPlural: isPlural ?? this.isPlural,
      pluralForms: pluralForms ?? this.pluralForms,
    );
  }

  /// Gets the appropriate plural form for given count.
  String getPlural(int count) {
    if (!isPlural || pluralForms == null) return value;
    
    // Simple plural logic for most languages
    if (count == 0 && pluralForms!.containsKey('zero')) {
      return pluralForms!['zero']!;
    } else if (count == 1 && pluralForms!.containsKey('one')) {
      return pluralForms!['one']!;
    } else if (pluralForms!.containsKey('other')) {
      return pluralForms!['other']!;
    }
    
    return value;
  }

  @override
  String toString() => 'FastTranslation($key: $value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FastTranslation &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          languageCode == other.languageCode;

  @override
  int get hashCode => key.hashCode ^ languageCode.hashCode;
}
