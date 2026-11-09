import 'package:flutter/material.dart';
import 'package:to_do_app/model/task_model.dart';
import 'package:to_do_app/model/task_stats.dart';

/// Estado de uma task. Substitui o progresso 0..100 como fonte da verdade.
///
/// O valor persistido de `done` continua sendo 'complete' (e não 'done') porque
/// é o que as bases locais e o Firebase já gravavam — trocar invalidaria tudo
/// que foi criado antes.
enum TaskStatus {
  todo('todo', 0, 'status_todo', Colors.white38, 'ToDo'),
  inProgress('inProgress', 50, 'status_in_progress', Colors.purpleAccent,
      'InProgress'),
  done('complete', kCompleteProgress, 'status_done', Colors.pinkAccent, 'Done');

  const TaskStatus(
    this.storageValue,
    this.progressValue,
    this.labelKey,
    this.color,
    this.filterValue,
  );

  /// Valor gravado na coluna `status` (local e Firebase).
  final String storageValue;

  /// Valor derivado gravado em `progress`. Mantido só por compatibilidade com
  /// bases antigas e com quem ainda lê o campo numérico.
  final int progressValue;

  /// Chave de tradução do rótulo (ver common_tr.dart).
  final String labelKey;

  /// Cor de destaque — as mesmas já usadas nos contadores do dashboard.
  final Color color;

  /// Valor usado no dropdown de filtro da home.
  final String filterValue;

  String get progressText => progressValue.toString();

  /// Lê o estado de uma task.
  ///
  /// `status` manda. Quando ele não bate com nenhum estado conhecido — dado
  /// antigo, que gravava só 'complete'/'unComplete', ou o literal 'null' que o
  /// sync do Firebase produz — cai no progresso: 0 é a fazer, 1..99 é em
  /// progresso, 100 é concluído.
  static TaskStatus from(TaskModel task) =>
      fromParts(status: task.status, progress: task.progress);

  static TaskStatus fromParts({String? status, String? progress}) {
    final raw = (status ?? '').trim().toLowerCase();
    for (final value in TaskStatus.values) {
      if (raw == value.storageValue.toLowerCase()) return value;
    }

    final percent = TaskStats.parseProgress(progress);
    if (percent >= kCompleteProgress) return TaskStatus.done;
    if (percent > 0) return TaskStatus.inProgress;
    return TaskStatus.todo;
  }

  /// Converte o valor do dropdown de filtro de volta para o estado.
  /// 'All' (ou qualquer coisa desconhecida) devolve null = não filtra.
  static TaskStatus? fromFilterValue(String value) {
    for (final status in TaskStatus.values) {
      if (status.filterValue == value) return status;
    }
    return null;
  }
}
