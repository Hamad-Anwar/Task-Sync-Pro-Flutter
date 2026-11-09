import 'package:intl/intl.dart';
import 'package:to_do_app/model/task_model.dart';
import 'package:to_do_app/model/task_status.dart';

/// Teto do campo legado `progress`, ainda gravado (derivado do status) para
/// compatibilidade com bases antigas.
const int kCompleteProgress = 100;

/// Recorte de estatísticas de um grupo de tasks (uma categoria, uma prioridade).
class GroupStat {
  final String label;
  final int total;
  final int completed;

  const GroupStat({
    required this.label,
    required this.total,
    required this.completed,
  });

  /// 0..100. Grupo vazio vale 0.
  double get percent => total == 0 ? 0 : (completed * 100) / total;
}

/// Estatísticas agregadas das tasks, calculadas sem tocar em banco, rede ou UI.
class TaskStats {
  final int total;
  final int completed;
  final int inProgress;
  final int notStarted;
  final int overdue;
  final List<GroupStat> byCategory;
  final List<GroupStat> byPriority;

  const TaskStats({
    required this.total,
    required this.completed,
    required this.inProgress,
    required this.notStarted,
    required this.overdue,
    required this.byCategory,
    required this.byPriority,
  });

  /// 0..100. Sem tasks vale 0.
  double get completionPercent => total == 0 ? 0 : (completed * 100) / total;

  bool get isEmpty => total == 0;

  /// Tasks deletadas são soft-deleted (show='no') e continuam na lista — ficam de fora.
  factory TaskStats.from(List<dynamic> tasks, {DateTime? now}) {
    final today = _atMidnight(now ?? DateTime.now());

    final visible = tasks
        .whereType<TaskModel>()
        .where((t) => t.show == 'yes')
        .toList();

    int completed = 0;
    int inProgress = 0;
    int notStarted = 0;
    int overdue = 0;

    final categoryTotals = <String, int>{};
    final categoryDone = <String, int>{};
    final priorityTotals = <String, int>{};
    final priorityDone = <String, int>{};

    for (final task in visible) {
      final status = TaskStatus.from(task);
      final isComplete = status == TaskStatus.done;

      switch (status) {
        case TaskStatus.done:
          completed++;
        case TaskStatus.inProgress:
          inProgress++;
        case TaskStatus.todo:
          notStarted++;
      }

      final due = parseDate(task.date);
      if (!isComplete && due != null && due.isBefore(today)) {
        overdue++;
      }

      final category = _label(task.category, fallback: 'Sem categoria');
      categoryTotals[category] = (categoryTotals[category] ?? 0) + 1;
      categoryDone[category] = (categoryDone[category] ?? 0) + (isComplete ? 1 : 0);

      final priority = _label(task.periority, fallback: 'Low');
      priorityTotals[priority] = (priorityTotals[priority] ?? 0) + 1;
      priorityDone[priority] = (priorityDone[priority] ?? 0) + (isComplete ? 1 : 0);
    }

    final categories = categoryTotals.keys
        .map((label) => GroupStat(
              label: label,
              total: categoryTotals[label]!,
              completed: categoryDone[label]!,
            ))
        .toList()
      ..sort((a, b) {
        final byTotal = b.total.compareTo(a.total);
        return byTotal != 0 ? byTotal : a.label.compareTo(b.label);
      });

    final priorities = priorityTotals.keys
        .map((label) => GroupStat(
              label: label,
              total: priorityTotals[label]!,
              completed: priorityDone[label]!,
            ))
        .toList()
      ..sort((a, b) => _priorityRank(a.label).compareTo(_priorityRank(b.label)));

    return TaskStats(
      total: visible.length,
      completed: completed,
      inProgress: inProgress,
      notStarted: notStarted,
      overdue: overdue,
      byCategory: categories,
      byPriority: priorities,
    );
  }

  /// Lê o campo legado `progress`. Vem do banco como texto e pode trazer '' ou
  /// a string literal 'null' (o sync do Firebase faz toString() em valor nulo).
  /// Fora da faixa, faz clamp. Só é usado como fallback em TaskStatus.from.
  static int parseProgress(String? raw) {
    final value = int.tryParse((raw ?? '').trim());
    if (value == null) return 0;
    return value.clamp(0, kCompleteProgress);
  }

  /// Datas são gravadas como 'd MMM y' e lidas em outros pontos como 'dd MMM yyyy'.
  /// Retorna null em vez de lançar quando o texto não casa com nenhum dos dois.
  static DateTime? parseDate(String? raw) {
    final text = (raw ?? '').trim();
    if (text.isEmpty || text == 'null') return null;

    for (final pattern in const ['d MMM y', 'dd MMM yyyy']) {
      try {
        return _atMidnight(DateFormat(pattern).parseLoose(text));
      } catch (_) {
        // tenta o próximo formato
      }
    }
    return null;
  }

  static String _label(String? raw, {required String fallback}) {
    final text = (raw ?? '').trim();
    return (text.isEmpty || text == 'null') ? fallback : text;
  }

  static int _priorityRank(String label) {
    switch (label) {
      case 'High':
        return 0;
      case 'Medium':
        return 1;
      case 'Low':
        return 2;
      default:
        return 3;
    }
  }

  static DateTime _atMidnight(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
