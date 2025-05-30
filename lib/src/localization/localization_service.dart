import 'dart:convert';
import 'package:flutter/services.dart';

/// Service for loading and accessing localized strings.
///
/// Use this class to load language files and retrieve translations by key.
class LocalizationService {
  /// The locale code (e.g., 'en', 'tr').
  final String locale;

  /// The loaded localized strings.
  Map<String, String> _localizedStrings = {};

  /// Creates a [LocalizationService] for the given [locale].
  LocalizationService(this.locale);

  /// Loads the localization file for the current [locale].
  ///
  /// Returns a [Future] that completes when the file is loaded.
  Future<void> load() async {
    String jsonString =
        await rootBundle.loadString('lib/src/localization/l10n/$locale.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings =
        jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }

  /// Returns the localized string for the given [key].
  ///
  /// If the key is not found, returns the key itself.
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}
