import 'dart:convert';
import 'package:flutter/services.dart';
import 'model/fast_language.dart';
import 'model/fast_translation.dart';

/// Advanced localization service with runtime language switching,
/// dynamic translation loading, and user preference management.
class FastLocalization {
  static FastLocalization? _instance;
  static FastLocalization get instance => _instance ??= FastLocalization._();
  FastLocalization._();

  /// Current language
  FastLanguage _currentLanguage = FastLanguage.english;
  FastLanguage get currentLanguage => _currentLanguage;

  /// Available languages
  final List<FastLanguage> _availableLanguages = [
    FastLanguage.english,
    FastLanguage.turkish,
  ];
  List<FastLanguage> get availableLanguages =>
      List.unmodifiable(_availableLanguages);

  /// Current translations map: key -> translation
  final Map<String, FastTranslation> _translations = {};

  /// Fallback translations (default language)
  final Map<String, FastTranslation> _fallbackTranslations = {};

  /// Default/fallback language
  FastLanguage _defaultLanguage = FastLanguage.english;
  FastLanguage get defaultLanguage => _defaultLanguage;

  /// Language change listeners
  final List<Function(FastLanguage)> _listeners = [];

  /// Initialize localization system
  Future<void> initialize({
    FastLanguage? defaultLanguage,
    List<FastLanguage>? supportedLanguages,
    String? userPreferredLanguage,
  }) async {
    if (defaultLanguage != null) {
      _defaultLanguage = defaultLanguage;
    }

    if (supportedLanguages != null) {
      _availableLanguages.clear();
      _availableLanguages.addAll(supportedLanguages);
    }

    // Load default language translations
    await _loadLanguageTranslations(_defaultLanguage);
    _fallbackTranslations.addAll(_translations);

    // Set user preferred language or use default
    if (userPreferredLanguage != null) {
      final preferredLangs = _availableLanguages
          .where((lang) => lang.code == userPreferredLanguage);
      if (preferredLangs.isNotEmpty) {
        await changeLanguage(preferredLangs.first);
      }
    } else {
      _currentLanguage = _defaultLanguage;
    }
  }

  /// Load translations from assets for a specific language
  Future<void> _loadLanguageTranslations(FastLanguage language) async {
    try {
      final jsonString = await rootBundle.loadString(
        'packages/fast_common_module/lib/src/localization/l10n/${language.code}.json',
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      _translations.clear();
      jsonMap.forEach((key, value) {
        _translations[key] = FastTranslation(
          id: '${language.code}_$key',
          key: key,
          value: value.toString(),
          languageCode: language.code,
        );
      });
    } catch (e) {
      // Handle asset loading error - maybe file doesn't exist
      print('Failed to load translations for ${language.code}: $e');
    }
  }

  /// Change current language
  Future<void> changeLanguage(FastLanguage language) async {
    if (!_availableLanguages.contains(language)) {
      throw ArgumentError('Language ${language.code} is not supported');
    }

    _currentLanguage = language;
    await _loadLanguageTranslations(language);

    // Notify all listeners
    for (final listener in _listeners) {
      listener(language);
    }
  }

  /// Add a language change listener
  void addLanguageListener(Function(FastLanguage) listener) {
    _listeners.add(listener);
  }

  /// Remove a language change listener
  void removeLanguageListener(Function(FastLanguage) listener) {
    _listeners.remove(listener);
  }

  /// Add or update a translation dynamically
  void addTranslation(FastTranslation translation) {
    _translations[translation.key] = translation;
  }

  /// Add multiple translations
  void addTranslations(List<FastTranslation> translations) {
    for (final translation in translations) {
      _translations[translation.key] = translation;
    }
  }

  /// Remove a translation
  void removeTranslation(String key) {
    _translations.remove(key);
  }

  /// Get translation for a key
  String translate(
    String key, {
    Map<String, dynamic>? params,
    int? count,
    String? fallback,
  }) {
    FastTranslation? translation = _translations[key];

    // Try fallback if not found in current language
    if (translation == null && _fallbackTranslations.containsKey(key)) {
      translation = _fallbackTranslations[key];
    }

    if (translation == null) {
      return fallback ?? key;
    }

    String result =
        count != null ? translation.getPlural(count) : translation.value;

    // Replace parameters if provided
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        result = result.replaceAll('{$paramKey}', paramValue.toString());
      });
    }

    return result;
  }

  /// Shorthand for translate
  String tr(
    String key, {
    Map<String, dynamic>? params,
    int? count,
    String? fallback,
  }) =>
      translate(key, params: params, count: count, fallback: fallback);

  /// Add a new supported language
  void addSupportedLanguage(FastLanguage language) {
    if (!_availableLanguages.contains(language)) {
      _availableLanguages.add(language);
    }
  }

  /// Remove a supported language
  void removeSupportedLanguage(FastLanguage language) {
    if (language != _defaultLanguage) {
      _availableLanguages.remove(language);
    }
  }

  /// Check if a language is supported
  bool isLanguageSupported(String languageCode) {
    return _availableLanguages.any((lang) => lang.code == languageCode);
  }

  /// Get language by code
  FastLanguage? getLanguageByCode(String code) {
    final languages = _availableLanguages.where((lang) => lang.code == code);
    return languages.isNotEmpty ? languages.first : null;
  }

  /// Load translations from external source (API, file, etc.)
  Future<void> loadTranslationsFromMap(
    String languageCode,
    Map<String, dynamic> translationsMap,
  ) async {
    final language = getLanguageByCode(languageCode);
    if (language == null) return;

    translationsMap.forEach((key, value) {
      _translations[key] = FastTranslation(
        id: '${languageCode}_$key',
        key: key,
        value: value.toString(),
        languageCode: languageCode,
      );
    });
  }

  /// Get all current translations
  Map<String, FastTranslation> get currentTranslations =>
      Map.unmodifiable(_translations);

  /// Clear all dynamic translations (keeps asset-loaded translations)
  void clearDynamicTranslations() {
    // This would require tracking which translations are dynamic
    // For simplicity, we'll reload from assets
    _loadLanguageTranslations(_currentLanguage);
  }

  /// Dispose of resources
  void dispose() {
    _listeners.clear();
    _translations.clear();
    _fallbackTranslations.clear();
  }
}

/// Extension for easy access to localization in widgets
extension LocalizationExtension on String {
  /// Translate this string using FastLocalization
  String get tr => FastLocalization.instance.translate(this);

  /// Translate with parameters
  String trParams(Map<String, dynamic> params) =>
      FastLocalization.instance.translate(this, params: params);

  /// Translate with count for pluralization
  String trPlural(int count) =>
      FastLocalization.instance.translate(this, count: count);
}
