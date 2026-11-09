import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_app/model/task_filter.dart';
import 'package:to_do_app/model/task_model.dart';

/// Mesmo helper de task_stats_test: defaults sensatos, sobrescreva só o que
/// o caso exige.
TaskModel makeTask({
  String? key = '1',
  String? title = 'Task',
  String? category = 'Work',
  String? description = 'desc',
  String? image = 'img.png',
  String? periority = 'Low',
  String? time = '10:00 AM',
  String? date = '5 Sep 2026',
  String? show = 'yes',
  String? progress = '0',
  String? status = 'pending',
}) {
  return TaskModel(
    key: key,
    title: title,
    category: category,
    description: description,
    image: image,
    periority: periority,
    time: time,
    date: date,
    show: show,
    progress: progress,
    status: status,
  );
}

List<String?> keysOf(List<TaskModel> tasks) =>
    tasks.map((t) => t.key).toList();

void main() {
  group('defaults (All/All, sem busca)', () {
    test('retorna só as visíveis, na ordem original', () {
      final result = TaskFilter.apply([
        makeTask(key: '1'),
        makeTask(key: '2', show: 'no'),
        makeTask(key: '3'),
      ]);

      expect(keysOf(result), ['1', '3']);
    });

    test('lista vazia não quebra', () {
      expect(TaskFilter.apply([]), isEmpty);
    });

    test('itens que não são TaskModel são ignorados', () {
      expect(TaskFilter.apply(['lixo', 42, null, makeTask(key: '1')]).length, 1);
    });
  });

  group('filtro por prioridade', () {
    final tasks = [
      makeTask(key: 'h', periority: 'High'),
      makeTask(key: 'm', periority: 'Medium'),
      makeTask(key: 'l', periority: 'Low'),
      makeTask(key: 'n', periority: null),
    ];

    test("'All' mantém todas", () {
      expect(TaskFilter.apply(tasks, priority: 'All').length, 4);
    });

    test('High/Medium/Low filtram exato', () {
      expect(keysOf(TaskFilter.apply(tasks, priority: 'High')), ['h']);
      expect(keysOf(TaskFilter.apply(tasks, priority: 'Medium')), ['m']);
    });

    test("prioridade null/vazia/'null' conta como Low (igual TaskStats)", () {
      expect(keysOf(TaskFilter.apply(tasks, priority: 'Low')), ['l', 'n']);
      expect(TaskFilter.effectivePriority(''), 'Low');
      expect(TaskFilter.effectivePriority('null'), 'Low');
      expect(TaskFilter.effectivePriority(' High '), 'High');
    });
  });

  group('filtro por status', () {
    final tasks = [
      makeTask(key: 'done', status: 'complete'),
      makeTask(key: 'doing', status: 'inProgress'),
      makeTask(key: 'todo', status: 'todo'),
      // dados antigos: status legado + progresso como fallback
      makeTask(key: 'legacyDone', status: 'unComplete', progress: '100'),
      makeTask(key: 'legacyClamped', status: 'unComplete', progress: '150'),
      makeTask(key: 'legacyHalf', status: 'unComplete', progress: '50'),
      makeTask(key: 'legacyZero', status: 'unComplete', progress: '0'),
      makeTask(key: 'dirty', status: 'null', progress: 'null'),
    ];

    test("'Done' pega status 'complete' e o legado com progresso 100", () {
      expect(keysOf(TaskFilter.apply(tasks, status: 'Done')),
          ['done', 'legacyDone', 'legacyClamped']);
    });

    test("'InProgress' pega o status novo e o legado entre 1 e 99", () {
      expect(keysOf(TaskFilter.apply(tasks, status: 'InProgress')),
          ['doing', 'legacyHalf']);
    });

    test("'ToDo' pega o status novo, o legado em 0 e o dado sujo", () {
      expect(keysOf(TaskFilter.apply(tasks, status: 'ToDo')),
          ['todo', 'legacyZero', 'dirty']);
    });

    test('os tr\u00eas estados juntos cobrem a lista inteira', () {
      final total = ['ToDo', 'InProgress', 'Done']
          .map((s) => TaskFilter.apply(tasks, status: s).length)
          .reduce((a, b) => a + b);
      expect(total, tasks.length);
    });

    test("'All' mantém todas", () {
      expect(TaskFilter.apply(tasks, status: 'All').length, tasks.length);
    });

    test('status desconhecido não filtra nada', () {
      expect(TaskFilter.apply(tasks, status: 'Whatever').length, tasks.length);
    });

    test('isCompleted ignora caixa e espaços no status', () {
      expect(TaskFilter.isCompleted(makeTask(status: ' Complete ')), isTrue);
      expect(
          TaskFilter.isCompleted(makeTask(status: 'unComplete', progress: '0')),
          isFalse);
      expect(TaskFilter.isCompleted(makeTask(status: null, progress: '0')),
          isFalse);
    });
  });

  group('busca por texto', () {
    final tasks = [
      makeTask(key: '1', title: 'Relatório', category: 'Work'),
      makeTask(key: '2', title: 'Compras', category: 'Home'),
      makeTask(key: '3', title: 'App', description: 'refazer o relatório'),
    ];

    test('case-insensitive sobre title, category e description', () {
      expect(keysOf(TaskFilter.apply(tasks, query: 'relatório')), ['1', '3']);
      expect(keysOf(TaskFilter.apply(tasks, query: 'HOME')), ['2']);
    });

    test('query vazia ou só espaços não filtra nada', () {
      expect(TaskFilter.apply(tasks, query: '   ').length, 3);
    });

    test('sem match retorna lista vazia sem lançar', () {
      expect(TaskFilter.apply(tasks, query: 'xyz-inexistente'), isEmpty);
    });

    test('campos null não quebram a busca', () {
      final result = TaskFilter.apply(
        [makeTask(key: '1', title: null, category: null, description: null)],
        query: 'a',
      );
      expect(result, isEmpty);
    });
  });

  group('composição busca + filtros', () {
    test('todos os critérios se aplicam ao mesmo tempo', () {
      final tasks = [
        makeTask(key: 'alvo', title: 'Report', periority: 'High',
            status: 'complete'),
        makeTask(key: '2', title: 'Report', periority: 'High',
            status: 'inProgress'),
        makeTask(key: '3', title: 'Report', periority: 'Low',
            status: 'complete'),
        makeTask(key: '4', title: 'Outra', periority: 'High',
            status: 'complete'),
        makeTask(key: '5', title: 'Report', periority: 'High',
            status: 'complete', show: 'no'),
      ];

      final result = TaskFilter.apply(
        tasks,
        query: 'report',
        priority: 'High',
        status: 'Done',
      );

      expect(keysOf(result), ['alvo']);
    });
  });
}
