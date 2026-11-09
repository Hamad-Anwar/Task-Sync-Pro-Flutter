import 'package:get/get.dart';

/// Chaves compartilhadas entre módulos (valores de prioridade/status são
/// persistidos em inglês no banco — aqui é SÓ exibição).
const Map<String, String> commonEn = {
  'priority_low': 'Low',
  'priority_medium': 'Medium',
  'priority_high': 'High',
  'filter_all': 'All',
  'status_todo': 'To do',
  'status_in_progress': 'In progress',
  'status_done': 'Done',
};

const Map<String, String> commonPt = {
  'priority_low': 'Baixa',
  'priority_medium': 'Média',
  'priority_high': 'Alta',
  'filter_all': 'Todas',
  'status_todo': 'A fazer',
  'status_in_progress': 'Em progresso',
  'status_done': 'Concluído',
};

/// Traduz um VALOR de prioridade/status/filtro (ex.: 'Low', 'InProgress', 'All')
/// para o rótulo no idioma atual. Valores desconhecidos voltam como estão.
String trValue(String value) {
  switch (value) {
    case 'Low':
      return 'priority_low'.tr;
    case 'Medium':
      return 'priority_medium'.tr;
    case 'High':
      return 'priority_high'.tr;
    case 'All':
      return 'filter_all'.tr;
    case 'ToDo':
      return 'status_todo'.tr;
    case 'InProgress':
      return 'status_in_progress'.tr;
    case 'Done':
      return 'status_done'.tr;
    default:
      return value;
  }
}
