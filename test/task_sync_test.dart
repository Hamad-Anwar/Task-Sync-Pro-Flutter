import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_app/data/sync/task_sync.dart';
import 'package:to_do_app/model/task_model.dart';

TaskModel makeTask(String key, {String status = 'todo'}) => TaskModel(
      key: key,
      title: 'Task $key',
      category: 'Work',
      description: 'desc',
      image: 'img.png',
      periority: 'Low',
      time: '10:00 AM',
      date: '5 Sep 2026',
      show: 'yes',
      progress: '0',
      status: status,
    );

class FakeStore implements TaskLocalStore {
  final Map<String, TaskModel> uploads = {};
  final Map<String, TaskModel> deletes = {};

  @override
  Future<List<TaskModel>> getPendingUploads() async => uploads.values.toList();

  @override
  Future<List<TaskModel>> getPendingDeletes() async => deletes.values.toList();

  @override
  Future<void> removePendingUpload(TaskModel sent) async {
    if (identical(uploads[sent.key], sent)) uploads.remove(sent.key);
  }

  @override
  Future<void> removePendingDelete(String key) async => deletes.remove(key);
}

class FakeRemote implements TaskRemote {
  final List<String> pushed = [];
  final List<String> hidden = [];
  Set<String> failOn = {};
  Completer<void>? gate;

  @override
  Future<void> push(TaskModel task) async {
    if (gate != null) await gate!.future;
    if (failOn.contains(task.key)) throw Exception('offline');
    pushed.add(task.key!);
  }

  @override
  Future<void> hide(String key) async {
    if (failOn.contains(key)) throw Exception('offline');
    hidden.add(key);
  }
}

class ThrowingStore extends FakeStore {
  @override
  Future<List<TaskModel>> getPendingUploads() async =>
      throw StateError('banco local indisponível');
}

void main() {
  late FakeStore store;
  late FakeRemote remote;
  late TaskSync sync;

  setUp(() {
    store = FakeStore();
    remote = FakeRemote();
    sync = TaskSync(store, remote, timeout: const Duration(milliseconds: 50));
  });

  test('envio confirmado tira da fila', () async {
    store.uploads['1'] = makeTask('1');
    store.deletes['2'] = makeTask('2');

    expect(await sync.run(), isTrue);
    expect(remote.pushed, ['1']);
    expect(remote.hidden, ['2']);
    expect(store.uploads, isEmpty);
    expect(store.deletes, isEmpty);
  });

  test('falha no envio mantém a task pendente', () async {
    store.uploads['1'] = makeTask('1');
    store.uploads['2'] = makeTask('2');
    remote.failOn = {'1'};

    expect(await sync.run(), isFalse);
    // a que falhou continua pendente; a outra não fica refém dela
    expect(store.uploads.keys, ['1']);
    expect(remote.pushed, ['2']);

    remote.failOn = {};
    expect(await sync.run(), isTrue);
    expect(store.uploads, isEmpty);
  });

  test('timeout (Firebase sem resposta) mantém a task pendente', () async {
    store.uploads['1'] = makeTask('1');
    remote.gate = Completer<void>();

    expect(await sync.run(), isFalse);
    expect(store.uploads.keys, ['1']);
  });

  test('task alterada durante o envio é reenviada na mesma execução', () async {
    store.uploads['1'] = makeTask('1');
    remote.gate = Completer<void>();
    sync = TaskSync(store, remote);

    final running = sync.run();
    await Future<void>.delayed(Duration.zero);
    store.uploads['1'] = makeTask('1', status: 'complete');
    remote.gate!.complete();

    expect(await running, isTrue);
    expect(remote.pushed, ['1', '1']);
    expect(store.uploads, isEmpty);
  });

  test('chamadas simultâneas não enviam duas vezes', () async {
    store.uploads['1'] = makeTask('1');
    remote.gate = Completer<void>();
    sync = TaskSync(store, remote);

    final a = sync.run();
    final b = sync.run();
    remote.gate!.complete();
    await Future.wait([a, b]);

    expect(remote.pushed, ['1']);
  });

  test('task nova pedida durante uma execução não fica esquecida', () async {
    store.uploads['1'] = makeTask('1');
    remote.gate = Completer<void>();
    sync = TaskSync(store, remote);

    final a = sync.run();
    await Future<void>.delayed(Duration.zero);
    store.uploads['2'] = makeTask('2');
    final b = sync.run();
    remote.gate!.complete();

    expect(await a, isTrue);
    expect(await b, isTrue);
    expect(remote.pushed, containsAll(['1', '2']));
    expect(store.uploads, isEmpty);
  });

  test('task com erro não trava as outras da fila', () async {
    store.uploads['1'] = makeTask('1');
    store.uploads['2'] = makeTask('2');
    store.uploads['3'] = makeTask('3');
    remote.failOn = {'1'};

    expect(await sync.run(), isFalse);
    expect(remote.pushed, ['2', '3']);
    expect(store.uploads.keys, ['1']);
  });

  test('erro ao ler a fila local não estoura exceção', () async {
    sync = TaskSync(ThrowingStore(), remote);

    expect(await sync.run(), isFalse);
    expect(sync.lastError, isNotNull);
  });

  test('falha agenda nova tentativa sozinha e para quando dá certo', () async {
    store.uploads['1'] = makeTask('1');
    remote.failOn = {'1'};
    sync = TaskSync(store, remote,
        retryBase: const Duration(milliseconds: 10),
        retryMax: const Duration(milliseconds: 40));

    expect(await sync.run(), isFalse);
    expect(sync.consecutiveFailures, 1);

    remote.failOn = {};
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(store.uploads, isEmpty);
    expect(sync.consecutiveFailures, 0);
    sync.dispose();
  });

  test('dispose cancela a nova tentativa agendada', () async {
    store.uploads['1'] = makeTask('1');
    remote.failOn = {'1'};
    sync = TaskSync(store, remote, retryBase: const Duration(milliseconds: 10));

    expect(await sync.run(), isFalse);
    sync.dispose();
    remote.failOn = {};
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(store.uploads.keys, ['1']);
  });
}
