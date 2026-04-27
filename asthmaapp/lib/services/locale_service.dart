import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  static const String _prefsKey = 'app_locale';

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  static bool isSupported(Locale? locale) {
    if (locale == null) return false;
    return supportedLocales.any((l) => l.languageCode == locale.languageCode);
  }

  static Future<Locale?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code == null || code.isEmpty) return null;
    final locale = Locale(code);
    return isSupported(locale) ? locale : null;
  }

  static Future<void> save(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefsKey);
      return;
    }
    await prefs.setString(_prefsKey, locale.languageCode);
  }
}

