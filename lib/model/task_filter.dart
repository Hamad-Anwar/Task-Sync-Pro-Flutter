import 'package:to_do_app/model/task_model.dart';
import 'package:to_do_app/model/task_status.dart';

/// Filtro puro de tasks (sem banco, rede ou UI) para a home page.
/// Combina busca por texto + prioridade + status.
class TaskFilter {
  static const List<String> priorities = ['All', 'High', 'Medium', 'Low'];
  static const List<String> statuses = ['All', 'ToDo', 'InProgress', 'Done'];

  /// Concluída = estado `done`. A leitura do estado (incluindo o fallback para
  /// o progresso das tasks antigas) mora em TaskStatus.from.
  static bool isCompleted(TaskModel task) =>
      TaskStatus.from(task) == TaskStatus.done;

  /// Prioridade vazia/null/'null' cai em 'Low', consistente com TaskStats.
  static String effectivePriority(String? raw) {
    final text = (raw ?? '').trim();
    return (text.isEmpty || text == 'null') ? 'Low' : text;
  }

  /// Aplica busca + filtros sobre a lista crua do controller.
  /// Tasks soft-deletadas (show != 'yes') ficam de fora, como no resto do app.
  static List<TaskModel> apply(
    List<dynamic> tasks, {
    String query = '',
    String priority = 'All',
    String status = 'All',
  }) {
    final q = query.trim().toLowerCase();
    final wanted = TaskStatus.fromFilterValue(status);

    bool matchesQuery(TaskModel task) {
      if (q.isEmpty) return true;
      bool has(String? field) => (field ?? '').toLowerCase().contains(q);
      return has(task.title) || has(task.category) || has(task.description);
    }

    bool matchesPriority(TaskModel task) =>
        priority == 'All' || effectivePriority(task.periority) == priority;

    bool matchesStatus(TaskModel task) =>
        wanted == null || TaskStatus.from(task) == wanted;

    return tasks
        .whereType<TaskModel>()
        .where((task) =>
            task.show == 'yes' &&
            matchesPriority(task) &&
            matchesStatus(task) &&
            matchesQuery(task))
        .toList();
  }
}
