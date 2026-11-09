import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../res/app_color.dart';
import '../../../res/translations/app_translations.dart';
import '../../../res/translations/language_service.dart';

/// Botão do header que abre o menu de idioma (English / Português BR).
class LanguageMenu extends StatelessWidget {
  const LanguageMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      color: primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Colors.white24),
      ),
      onSelected: LanguageService.setLanguage,
      itemBuilder: (context) => [
        _item(AppTranslations.en, 'English'),
        _item(AppTranslations.ptBr, 'Português (BR)'),
      ],
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white24),
        ),
        child: const Icon(
          Icons.language,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  PopupMenuItem<Locale> _item(Locale locale, String label) {
    final selected = (Get.locale ?? AppTranslations.fallback) == locale;
    return PopupMenuItem(
      value: locale,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.pinkAccent : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          if (selected)
            const Icon(Icons.check, color: Colors.pinkAccent, size: 16),
        ],
      ),
    );
  }
}
