import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_app/model/task_model.dart';
import 'package:to_do_app/model/task_status.dart';

TaskModel makeTask({String? status, String? progress}) => TaskModel(
      key: '1',
      title: 'Task',
      category: 'Work',
      description: 'desc',
      image: 'img.png',
      periority: 'Low',
      time: '10:00 AM',
      date: '5 Sep 2026',
      show: 'yes',
      progress: progress,
      status: status,
    );

void main() {
  group('leitura pelo campo status', () {
    test('reconhece os três valores gravados', () {
      expect(TaskStatus.fromParts(status: 'todo'), TaskStatus.todo);
      expect(TaskStatus.fromParts(status: 'inProgress'), TaskStatus.inProgress);
      expect(TaskStatus.fromParts(status: 'complete'), TaskStatus.done);
    });

    test('ignora caixa e espaços', () {
      expect(TaskStatus.fromParts(status: ' COMPLETE '), TaskStatus.done);
      expect(TaskStatus.fromParts(status: 'inprogress'), TaskStatus.inProgress);
    });

    test('status manda sobre o progresso quando os dois divergem', () {
      expect(TaskStatus.fromParts(status: 'todo', progress: '100'),
          TaskStatus.todo);
      expect(TaskStatus.fromParts(status: 'complete', progress: '0'),
          TaskStatus.done);
    });
  });

  group('fallback para o progresso (dados criados antes da mudança)', () {
    test("'unComplete' cai no progresso", () {
      expect(TaskStatus.fromParts(status: 'unComplete', progress: '0'),
          TaskStatus.todo);
      expect(TaskStatus.fromParts(status: 'unComplete', progress: '1'),
          TaskStatus.inProgress);
      expect(TaskStatus.fromParts(status: 'unComplete', progress: '99'),
          TaskStatus.inProgress);
      expect(TaskStatus.fromParts(status: 'unComplete', progress: '100'),
          TaskStatus.done);
    });

    test('progresso acima de 100 conta como concluído (clamp)', () {
      expect(TaskStatus.fromParts(status: null, progress: '150'),
          TaskStatus.done);
    });

    test("null, vazio, 'null' e lixo caem em todo", () {
      expect(TaskStatus.fromParts(), TaskStatus.todo);
      expect(TaskStatus.fromParts(status: '', progress: ''), TaskStatus.todo);
      expect(TaskStatus.fromParts(status: 'null', progress: 'null'),
          TaskStatus.todo);
      expect(TaskStatus.fromParts(status: 'xyz', progress: 'abc'),
          TaskStatus.todo);
    });

    test('from(task) usa os dois campos da TaskModel', () {
      expect(TaskStatus.from(makeTask(status: 'unComplete', progress: '40')),
          TaskStatus.inProgress);
    });
  });

  group('valores gravados', () {
    test('storageValue mantém complete para não invalidar base antiga', () {
      expect(TaskStatus.done.storageValue, 'complete');
      expect(TaskStatus.todo.storageValue, 'todo');
      expect(TaskStatus.inProgress.storageValue, 'inProgress');
    });

    test('progress derivado é 0/50/100', () {
      expect(TaskStatus.todo.progressText, '0');
      expect(TaskStatus.inProgress.progressText, '50');
      expect(TaskStatus.done.progressText, '100');
    });

    test('o que é gravado volta como o mesmo estado', () {
      for (final status in TaskStatus.values) {
        expect(
          TaskStatus.fromParts(
              status: status.storageValue, progress: status.progressText),
          status,
        );
      }
    });
  });

  group('valores de filtro', () {
    test('cada estado tem o seu', () {
      expect(TaskStatus.fromFilterValue('ToDo'), TaskStatus.todo);
      expect(TaskStatus.fromFilterValue('InProgress'), TaskStatus.inProgress);
      expect(TaskStatus.fromFilterValue('Done'), TaskStatus.done);
    });

    test("'All' e desconhecidos devolvem null (não filtram)", () {
      expect(TaskStatus.fromFilterValue('All'), isNull);
      expect(TaskStatus.fromFilterValue('Pending'), isNull);
      expect(TaskStatus.fromFilterValue(''), isNull);
    });
  });
}
