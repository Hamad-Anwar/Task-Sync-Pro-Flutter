import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_translations.dart';

class LanguageService {
  static const _prefKey = 'LANGUAGE';

  /// Locale salvo, ou inglês por padrão.
  static Future<Locale> savedLocale() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(_prefKey) == 'pt_BR'
        ? AppTranslations.ptBr
        : AppTranslations.en;
  }

  static Future<void> setLanguage(Locale locale) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(
        _prefKey, locale == AppTranslations.ptBr ? 'pt_BR' : 'en_US');
    Get.updateLocale(locale);
  }
}
