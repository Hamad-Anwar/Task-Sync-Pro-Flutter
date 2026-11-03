import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:to_do_app/utils/utils.dart';

/// Regras e avisos compartilhados pelos formulários de login e cadastro.
class FormValidation {
  /// Tamanho mínimo de senha aceito no login e no cadastro.
  static const int minPasswordLength = 6;

  /// Aviso de validação: título sign_warning, a mensagem traduzida de
  /// [messageKey] e ícone de alerta rosa.
  static void showWarning(String messageKey) {
    Utils.showSnackBar(
      'sign_warning'.tr,
      messageKey.tr,
      const Icon(FontAwesomeIcons.triangleExclamation, color: Colors.pink),
    );
  }
}
