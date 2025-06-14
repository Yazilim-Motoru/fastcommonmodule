import 'dart:convert';
import 'package:flutter/material.dart';
import 'fast_localization.dart';
import 'model/fast_language.dart';
import 'model/fast_translation.dart';

/// Controller for managing user language preferences with persistent storage.
class FastLocalizationController extends ChangeNotifier {
  final FastLocalization _localization = FastLocalization.instance;

  /// Storage interface for saving user preferences
  final Future<String?> Function(String key)? _getPreference;
  final Future<void> Function(String key, String value)? _setPreference;

  static const String _languagePreferenceKey = 'fast_localization_language';

  FastLocalizationController({
    Future<String?> Function(String key)? getPreference,
    Future<void> Function(String key, String value)? setPreference,
  })  : _getPreference = getPreference,
        _setPreference = setPreference {
    // Listen to localization changes
    _localization.addLanguageListener(_onLanguageChanged);
  }

  /// Current language
  FastLanguage get currentLanguage => _localization.currentLanguage;

  /// Available languages
  List<FastLanguage> get availableLanguages => _localization.availableLanguages;

  /// Default language
  FastLanguage get defaultLanguage => _localization.defaultLanguage;

  /// Current language direction (LTR/RTL)
  TextDirection get textDirection =>
      currentLanguage.isRTL ? TextDirection.rtl : TextDirection.ltr;

  /// Initialize with user preferences
  Future<void> initialize({
    FastLanguage? defaultLanguage,
    List<FastLanguage>? supportedLanguages,
  }) async {
    // Load saved language preference
    String? savedLanguageCode;
    if (_getPreference != null) {
      savedLanguageCode = await _getPreference!(_languagePreferenceKey);
    }

    await _localization.initialize(
      defaultLanguage: defaultLanguage,
      supportedLanguages: supportedLanguages,
      userPreferredLanguage: savedLanguageCode,
    );

    notifyListeners();
  }

  /// Change language and save preference
  Future<void> changeLanguage(FastLanguage language) async {
    await _localization.changeLanguage(language);

    // Save user preference
    if (_setPreference != null) {
      await _setPreference!(_languagePreferenceKey, language.code);
    }
  }

  /// Change language by code
  Future<void> changeLanguageByCode(String languageCode) async {
    final language = _localization.getLanguageByCode(languageCode);
    if (language != null) {
      await changeLanguage(language);
    }
  }

  /// Reset to default language
  Future<void> resetToDefault() async {
    await changeLanguage(defaultLanguage);
  }

  /// Add translation dynamically
  void addTranslation(String key, String value, {String? context}) {
    final translation = FastTranslation(
      id: '${currentLanguage.code}_$key',
      key: key,
      value: value,
      languageCode: currentLanguage.code,
      context: context,
    );
    _localization.addTranslation(translation);
  }

  /// Add multiple translations
  void addTranslations(Map<String, String> translations) {
    translations.forEach((key, value) {
      addTranslation(key, value);
    });
  }

  /// Load translations from JSON string
  Future<void> loadTranslationsFromJson(
    String languageCode,
    String jsonString,
  ) async {
    try {
      final Map<String, dynamic> translationsMap = json.decode(jsonString);
      await _localization.loadTranslationsFromMap(
          languageCode, translationsMap);
      notifyListeners();
    } catch (e) {
      throw FormatException('Invalid JSON format: $e');
    }
  }

  /// Load translations from Map
  Future<void> loadTranslationsFromMap(
    String languageCode,
    Map<String, dynamic> translationsMap,
  ) async {
    await _localization.loadTranslationsFromMap(languageCode, translationsMap);
    notifyListeners();
  }

  /// Get translation with fallback
  String translate(
    String key, {
    Map<String, dynamic>? params,
    int? count,
    String? fallback,
  }) {
    return _localization.translate(
      key,
      params: params,
      count: count,
      fallback: fallback,
    );
  }

  /// Shorthand for translate
  String tr(
    String key, {
    Map<String, dynamic>? params,
    int? count,
    String? fallback,
  }) =>
      translate(key, params: params, count: count, fallback: fallback);

  /// Check if a key has translation
  bool hasTranslation(String key) {
    return _localization.currentTranslations.containsKey(key);
  }

  /// Get all current translation keys
  List<String> get translationKeys =>
      _localization.currentTranslations.keys.toList();

  /// Language change handler
  void _onLanguageChanged(FastLanguage language) {
    notifyListeners();
  }

  @override
  void dispose() {
    _localization.removeLanguageListener(_onLanguageChanged);
    super.dispose();
  }
}

/// Widget that rebuilds when language changes
class FastLocalizationBuilder extends StatefulWidget {
  final Widget Function(
      BuildContext context, FastLocalizationController controller) builder;
  final FastLocalizationController? controller;

  const FastLocalizationBuilder({
    Key? key,
    required this.builder,
    this.controller,
  }) : super(key: key);

  @override
  State<FastLocalizationBuilder> createState() =>
      _FastLocalizationBuilderState();
}

class _FastLocalizationBuilderState extends State<FastLocalizationBuilder> {
  late FastLocalizationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? FastLocalizationController();
    _controller.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onLanguageChanged);
    }
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _controller);
  }
}
