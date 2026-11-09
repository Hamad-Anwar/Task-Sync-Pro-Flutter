import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'common_tr.dart';
import 'dashboard_tr.dart';
import 'home_tr.dart';
import 'sign_tr.dart';
import 'task_tr.dart';

class AppTranslations extends Translations {
  static const Locale en = Locale('en', 'US');
  static const Locale ptBr = Locale('pt', 'BR');
  static const Locale fallback = en;

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          ...commonEn,
          ...signEn,
          ...homeEn,
          ...taskEn,
          ...dashboardEn,
        },
        'pt_BR': {
          ...commonPt,
          ...signPt,
          ...homePt,
          ...taskPt,
          ...dashboardPt,
        },
      };
}
