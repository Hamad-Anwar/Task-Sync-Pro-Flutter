import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_app/model/task_model.dart';
import 'package:to_do_app/model/task_stats.dart';

/// Constrói um TaskModel com defaults sensatos para não poluir cada teste com
/// os 11 campos obrigatórios. Sobrescreva só o que o caso exige.
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

/// Data fixa usada como "hoje" em todos os testes que dependem de tempo.
final DateTime kNow = DateTime(2026, 9, 10);

GroupStat groupNamed(List<GroupStat> groups, String label) =>
    groups.firstWhere((g) => g.label == label);

void main() {
  group('lista vazia', () {
    test('não divide por zero e reporta tudo em 0', () {
      final stats = TaskStats.from([], now: kNow);

      expect(stats.total, 0);
      expect(stats.completed, 0);
      expect(stats.inProgress, 0);
      expect(stats.notStarted, 0);
      expect(stats.overdue, 0);
      expect(stats.completionPercent, 0);
      expect(stats.isEmpty, isTrue);
      expect(stats.byCategory, isEmpty);
      expect(stats.byPriority, isEmpty);
    });

    test('GroupStat vazio vale 0 em percent', () {
      const group = GroupStat(label: 'X', total: 0, completed: 0);
      expect(group.percent, 0);
    });

    test('lista só com itens que não são TaskModel é tratada como vazia', () {
      final stats = TaskStats.from(['lixo', 42, null], now: kNow);
      expect(stats.isEmpty, isTrue);
      expect(stats.total, 0);
    });
  });

  group("soft delete (show == 'no')", () {
    test('não entra no total nem na classificação', () {
      final stats = TaskStats.from([
        makeTask(key: '1', show: 'yes', progress: '100'),
        makeTask(key: '2', show: 'no', progress: '100'),
        makeTask(key: '3', show: 'no', progress: '50'),
        makeTask(key: '4', show: 'no', progress: '0'),
      ], now: kNow);

      expect(stats.total, 1);
      expect(stats.completed, 1);
      expect(stats.inProgress, 0);
      expect(stats.notStarted, 0);
      expect(stats.completionPercent, 100);
    });

    test('não entra na contagem de atrasadas', () {
      final stats = TaskStats.from([
        makeTask(key: '1', show: 'no', progress: '0', date: '1 Sep 2026'),
        makeTask(key: '2', show: 'no', progress: '10', date: '1 Sep 2026'),
      ], now: kNow);

      expect(stats.total, 0);
      expect(stats.overdue, 0);
    });

    test('não entra em byCategory nem em byPriority', () {
      final stats = TaskStats.from([
        makeTask(key: '1', show: 'yes', category: 'Work', periority: 'High'),
        makeTask(key: '2', show: 'no', category: 'Fantasma', periority: 'High'),
        makeTask(key: '3', show: 'no', category: 'Work', periority: 'Low'),
      ], now: kNow);

      expect(stats.byCategory.map((g) => g.label), ['Work']);
      expect(groupNamed(stats.byCategory, 'Work').total, 1);
      expect(stats.byPriority.map((g) => g.label), ['High']);
      expect(groupNamed(stats.byPriority, 'High').total, 1);
    });

    test('lista inteiramente soft-deletada equivale a lista vazia', () {
      final stats = TaskStats.from([
        makeTask(key: '1', show: 'no'),
        makeTask(key: '2', show: 'no'),
      ], now: kNow);

      expect(stats.isEmpty, isTrue);
      expect(stats.completionPercent, 0);
    });

    test('show diferente de yes/no também fica de fora', () {
      final stats = TaskStats.from([
        makeTask(key: '1', show: 'yes'),
        makeTask(key: '2', show: null),
        makeTask(key: '3', show: ''),
        makeTask(key: '4', show: 'NO'),
      ], now: kNow);

      expect(stats.total, 1);
    });
  });

  group('classificação por progresso', () {
    test('fronteira exata em 99, 100 e 101', () {
      final stats = TaskStats.from([
        makeTask(key: '99', progress: '99'),
        makeTask(key: '100', progress: '100'),
        makeTask(key: '101', progress: '101'),
      ], now: kNow);

      expect(stats.total, 3);
      // 101 sofre clamp para 100 e também conta como concluída.
      expect(stats.completed, 2);
      expect(stats.inProgress, 1);
      expect(stats.notStarted, 0);
    });

    test('progresso 0 é não iniciada e 1 já é em andamento', () {
      final stats = TaskStats.from([
        makeTask(key: '1', progress: '0'),
        makeTask(key: '2', progress: '1'),
      ], now: kNow);

      expect(stats.notStarted, 1);
      expect(stats.inProgress, 1);
      expect(stats.completed, 0);
    });

    test('mistura fecha a soma e o percentual', () {
      final stats = TaskStats.from([
        makeTask(key: '1', progress: '100'),
        makeTask(key: '2', progress: '100'),
        makeTask(key: '3', progress: '50'),
        makeTask(key: '4', progress: '0'),
      ], now: kNow);

      expect(stats.total, 4);
      expect(stats.completed, 2);
      expect(stats.inProgress, 1);
      expect(stats.notStarted, 1);
      expect(stats.completed + stats.inProgress + stats.notStarted, stats.total);
      expect(stats.completionPercent, 50);
      expect(stats.isEmpty, isFalse);
    });
  });

  group('parseProgress', () {
    test('null vira 0', () {
      expect(TaskStats.parseProgress(null), 0);
    });

    test('string vazia vira 0', () {
      expect(TaskStats.parseProgress(''), 0);
      expect(TaskStats.parseProgress('   '), 0);
    });

    test("string literal 'null' vira 0", () {
      expect(TaskStats.parseProgress('null'), 0);
    });

    test('texto não numérico vira 0', () {
      expect(TaskStats.parseProgress('abc'), 0);
      expect(TaskStats.parseProgress('50%'), 0);
    });

    test('negativo faz clamp em 0', () {
      expect(TaskStats.parseProgress('-10'), 0);
    });

    test('acima de 100 faz clamp em 100', () {
      expect(TaskStats.parseProgress('150'), 100);
    });

    test('valores válidos passam intactos e aceitam espaços', () {
      expect(TaskStats.parseProgress('0'), 0);
      expect(TaskStats.parseProgress('37'), 37);
      expect(TaskStats.parseProgress('100'), 100);
      expect(TaskStats.parseProgress(' 42 '), 42);
    });

    test('progresso sujo não quebra a agregação e conta como não iniciada', () {
      final stats = TaskStats.from([
        makeTask(key: '1', progress: null),
        makeTask(key: '2', progress: 'null'),
        makeTask(key: '3', progress: 'abc'),
        makeTask(key: '4', progress: '-10'),
      ], now: kNow);

      expect(stats.total, 4);
      expect(stats.notStarted, 4);
      expect(stats.completed, 0);
      expect(stats.inProgress, 0);
    });
  });

  group('parseDate', () {
    test("aceita 'd MMM y'", () {
      expect(TaskStats.parseDate('5 Sep 2026'), DateTime(2026, 9, 5));
    });

    test("aceita 'dd MMM yyyy'", () {
      expect(TaskStats.parseDate('05 Sep 2026'), DateTime(2026, 9, 5));
    });

    test('normaliza para meia-noite', () {
      final parsed = TaskStats.parseDate('5 Sep 2026')!;
      expect(parsed.hour, 0);
      expect(parsed.minute, 0);
      expect(parsed.second, 0);
    });

    test('null e vazio retornam null sem lançar', () {
      expect(TaskStats.parseDate(null), isNull);
      expect(TaskStats.parseDate(''), isNull);
      expect(TaskStats.parseDate('   '), isNull);
    });

    test("string literal 'null' retorna null sem lançar", () {
      expect(TaskStats.parseDate('null'), isNull);
    });

    test('texto inválido retorna null sem lançar', () {
      expect(TaskStats.parseDate('abc'), isNull);
      expect(TaskStats.parseDate('data invalida'), isNull);
      expect(TaskStats.parseDate('32 Xyz 2026'), isNull);
      expect(TaskStats.parseDate('2026-09-05'), isNull);
    });

    test('data parcial não vira silenciosamente uma data de 1970', () {
      // parseLoose é tolerante: se aceitasse campos faltando, o default cairia
      // no epoch e toda task com data quebrada apareceria como atrasada.
      for (final raw in const [
        '5 Sep',
        'Sep 2026',
        '5',
        'Sep',
        '5 Sep 2026 lixo',
        'undefined',
        '5/9/2026',
      ]) {
        expect(TaskStats.parseDate(raw), isNull, reason: 'entrada: "$raw"');
      }
    });

    test('data parcial não infla o contador de atrasadas', () {
      final stats = TaskStats.from([
        makeTask(key: '1', date: '5 Sep', progress: '0'),
        makeTask(key: '2', date: 'Sep 2026', progress: '0'),
        makeTask(key: '3', date: 'undefined', progress: '0'),
      ], now: kNow);

      expect(stats.total, 3);
      expect(stats.overdue, 0);
    });
  });

  group('atrasadas', () {
    test('data no passado com progresso < 100 conta como atrasada', () {
      final stats = TaskStats.from([
        makeTask(key: '1', date: '1 Sep 2026', progress: '0'),
        makeTask(key: '2', date: '01 Sep 2026', progress: '50'),
      ], now: kNow);

      expect(stats.overdue, 2);
    });

    test('data no passado com 100% NÃO conta', () {
      final stats = TaskStats.from([
        makeTask(key: '1', date: '1 Sep 2026', progress: '100'),
        makeTask(key: '2', date: '1 Sep 2026', progress: '150'),
      ], now: kNow);

      expect(stats.overdue, 0);
      expect(stats.completed, 2);
    });

    test('data futura não conta', () {
      final stats = TaskStats.from([
        makeTask(key: '1', date: '30 Sep 2026', progress: '0'),
      ], now: kNow);

      expect(stats.overdue, 0);
    });

    test('a data de hoje não conta como atrasada', () {
      final stats = TaskStats.from([
        makeTask(key: '1', date: '10 Sep 2026', progress: '0'),
      ], now: kNow);

      expect(stats.overdue, 0);
    });

    test('hora do dia em now não afeta o corte de hoje', () {
      final tasks = [makeTask(key: '1', date: '10 Sep 2026', progress: '0')];

      expect(TaskStats.from(tasks, now: DateTime(2026, 9, 10, 23, 59)).overdue, 0);
      expect(TaskStats.from(tasks, now: DateTime(2026, 9, 10, 0, 0)).overdue, 0);
      expect(TaskStats.from(tasks, now: DateTime(2026, 9, 11, 0, 1)).overdue, 1);
    });

    test('data inválida/ausente não conta e não lança', () {
      final stats = TaskStats.from([
        makeTask(key: '1', date: null, progress: '0'),
        makeTask(key: '2', date: '', progress: '0'),
        makeTask(key: '3', date: 'null', progress: '0'),
        makeTask(key: '4', date: 'abc', progress: '0'),
        makeTask(key: '5', date: 'data invalida', progress: '10'),
      ], now: kNow);

      expect(stats.total, 5);
      expect(stats.overdue, 0);
    });

    test('atrasadas nunca passam do total visível', () {
      final stats = TaskStats.from([
        makeTask(key: '1', date: '1 Sep 2026', progress: '0'),
        makeTask(key: '2', date: '1 Sep 2026', progress: '0', show: 'no'),
        makeTask(key: '3', date: '30 Sep 2026', progress: '0'),
      ], now: kNow);

      expect(stats.total, 2);
      expect(stats.overdue, 1);
    });
  });

  group('byCategory', () {
    test('agrupa e calcula percentuais por categoria', () {
      final stats = TaskStats.from([
        makeTask(key: '1', category: 'Work', progress: '100'),
        makeTask(key: '2', category: 'Work', progress: '0'),
        makeTask(key: '3', category: 'Work', progress: '50'),
        makeTask(key: '4', category: 'Home', progress: '100'),
      ], now: kNow);

      final work = groupNamed(stats.byCategory, 'Work');
      expect(work.total, 3);
      expect(work.completed, 1);
      expect(work.percent, closeTo(33.33, 0.01));

      final home = groupNamed(stats.byCategory, 'Home');
      expect(home.total, 1);
      expect(home.completed, 1);
      expect(home.percent, 100);
    });

    test('categoria vazia, null e literal null caem no fallback', () {
      final stats = TaskStats.from([
        makeTask(key: '1', category: null),
        makeTask(key: '2', category: ''),
        makeTask(key: '3', category: '   '),
        makeTask(key: '4', category: 'null'),
      ], now: kNow);

      expect(stats.byCategory.length, 1);
      expect(stats.byCategory.single.label, 'Sem categoria');
      expect(stats.byCategory.single.total, 4);
    });

    test('ordena por total desc e desempata por label', () {
      final stats = TaskStats.from([
        makeTask(key: '1', category: 'Zeta'),
        makeTask(key: '2', category: 'Alpha'),
        makeTask(key: '3', category: 'Work'),
        makeTask(key: '4', category: 'Work'),
        makeTask(key: '5', category: 'Work'),
      ], now: kNow);

      expect(stats.byCategory.map((g) => g.label).toList(),
          ['Work', 'Alpha', 'Zeta']);
      expect(stats.byCategory.map((g) => g.total).toList(), [3, 1, 1]);
    });

    test('soma dos totais por categoria bate com o total visível', () {
      final stats = TaskStats.from([
        makeTask(key: '1', category: 'Work'),
        makeTask(key: '2', category: 'Home'),
        makeTask(key: '3', category: null),
        makeTask(key: '4', category: 'Work', show: 'no'),
      ], now: kNow);

      final soma =
          stats.byCategory.fold<int>(0, (acc, g) => acc + g.total);
      expect(soma, stats.total);
      expect(soma, 3);
    });
  });

  group('byPriority', () {
    test('agrupa e calcula percentuais por prioridade', () {
      final stats = TaskStats.from([
        makeTask(key: '1', periority: 'High', progress: '100'),
        makeTask(key: '2', periority: 'High', progress: '0'),
        makeTask(key: '3', periority: 'Low', progress: '100'),
      ], now: kNow);

      final high = groupNamed(stats.byPriority, 'High');
      expect(high.total, 2);
      expect(high.completed, 1);
      expect(high.percent, 50);

      final low = groupNamed(stats.byPriority, 'Low');
      expect(low.total, 1);
      expect(low.percent, 100);
    });

    test("'High' vem primeiro mesmo tendo menos tasks", () {
      final stats = TaskStats.from([
        makeTask(key: '1', periority: 'Low'),
        makeTask(key: '2', periority: 'Low'),
        makeTask(key: '3', periority: 'Medium'),
        makeTask(key: '4', periority: 'High'),
      ], now: kNow);

      expect(stats.byPriority.first.label, 'High');
      expect(stats.byPriority.map((g) => g.label).toList(),
          ['High', 'Medium', 'Low']);
    });

    test('Medium agrupa e calcula percentual como as demais prioridades', () {
      final stats = TaskStats.from([
        makeTask(key: '1', periority: 'Medium', progress: '100'),
        makeTask(key: '2', periority: 'Medium', progress: '0'),
        makeTask(key: '3', periority: 'High'),
        makeTask(key: '4', periority: 'Low'),
      ], now: kNow);

      final medium = groupNamed(stats.byPriority, 'Medium');
      expect(medium.total, 2);
      expect(medium.completed, 1);
      expect(medium.percent, 50);
    });

    test('prioridade vazia, null e literal null caem no fallback Low', () {
      final stats = TaskStats.from([
        makeTask(key: '1', periority: null),
        makeTask(key: '2', periority: ''),
        makeTask(key: '3', periority: 'null'),
        makeTask(key: '4', periority: 'Low'),
      ], now: kNow);

      expect(stats.byPriority.length, 1);
      expect(stats.byPriority.single.label, 'Low');
      expect(stats.byPriority.single.total, 4);
    });

    test('soma dos totais por prioridade bate com o total visível', () {
      final stats = TaskStats.from([
        makeTask(key: '1', periority: 'High'),
        makeTask(key: '2', periority: 'Medium'),
        makeTask(key: '3', periority: null),
        makeTask(key: '4', periority: 'High', show: 'no'),
      ], now: kNow);

      final soma = stats.byPriority.fold<int>(0, (acc, g) => acc + g.total);
      expect(soma, stats.total);
      expect(soma, 3);
    });
  });
}
