import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:to_do_app/model/task_model.dart';
import 'package:to_do_app/view%20model/DbHelper/db_helper.dart';

TaskModel makeTask(String key,
        {String status = 'todo', String show = 'yes', String? updatedAt}) =>
    TaskModel(
      key: key,
      title: 'Task $key',
      category: 'Work',
      description: 'desc',
      image: 'img.png',
      periority: 'Low',
      time: '10:00 AM',
      date: '5 Sep 2026',
      show: show,
      progress: '0',
      status: status,
      updatedAt: updatedAt,
    );

void main() {
  late Database database;
  final db = DbHelper();

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
        options: OpenDatabaseOptions(
            version: 1,
            singleInstance: false,
            onCreate: (db, _) => DbHelper.createSchema(db)));
    await DbHelper.useDatabase(database);
  });

  tearDown(() async {
    await DbHelper.useDatabase(null);
    await database.close();
  });

  test('task criada offline aparece na lista e fica na fila', () async {
    await db.insert(makeTask('1'));

    expect((await db.getData()).map((t) => t.key), ['1']);
    expect((await db.getPendingUploads()).map((t) => t.key), ['1']);
  });

  test('mudança de status de task criada offline não se perde', () async {
    await db.insert(makeTask('1'));
    await db.update(makeTask('1', status: 'complete'));

    expect((await db.getData()).single.status, 'complete');
    expect((await db.getPendingUploads()).single.status, 'complete');
  });

  test('remoção offline vai para a fila com show = no', () async {
    await db.insert(makeTask('1'));
    await db.removeFromList(makeTask('1', show: 'no'));

    expect((await db.getData()).single.show, 'no');
    expect((await db.getPendingUploads()).single.show, 'no');
  });

  test('só tira da fila a versão que foi enviada', () async {
    final sent = makeTask('1');
    await db.insert(sent);
    await db.update(makeTask('1', status: 'complete'));

    await db.removePendingUpload(sent);
    expect((await db.getPendingUploads()).single.status, 'complete');

    final current = (await db.getPendingUploads()).single;
    await db.removePendingUpload(current);
    expect(await db.getPendingUploads(), isEmpty);
    expect((await db.getData()).single.status, 'complete');
  });

  test('dado do Firebase não sobrescreve alteração local pendente', () async {
    await db.insert(makeTask('1', status: 'complete'));

    expect(await db.saveFromRemote(makeTask('1')), isFalse);
    expect((await db.getData()).single.status, 'complete');

    expect(await db.saveFromRemote(makeTask('2')), isTrue);
    expect(await db.getPendingUploads(), hasLength(1));
  });

  test('task antiga só na fila (versão anterior) é recuperada para a lista',
      () async {
    await database.insert('PendingUploads', makeTask('old').toMap());
    await DbHelper.useDatabase(database);

    expect((await db.getData()).map((t) => t.key), ['old']);
  });

  test('pendingCount reflete a fila e zera quando tudo é enviado', () async {
    expect(await db.pendingCount(), 0);

    final sent = makeTask('1');
    await db.insert(sent);
    await db.insert(makeTask('2'));
    expect(await db.pendingCount(), 2);

    await db.removePendingUpload(sent);
    expect(await db.pendingCount(), 1);
  });

  test('toda edição local recebe um updatedAt maior que o anterior', () async {
    await db.insert(makeTask('1'));
    final first = (await db.getData()).single.updatedAtMillis;
    await db.update(makeTask('1', status: 'complete'));
    final second = (await db.getData()).single.updatedAtMillis;

    expect(first, greaterThan(0));
    expect(second, greaterThan(first));
    expect((await db.getPendingUploads()).single.updatedAtMillis, second);
  });

  test('remoto mais antigo não regride uma task já enviada', () async {
    await db.insert(makeTask('1', status: 'complete'));
    await db.removePendingUpload((await db.getPendingUploads()).single);
    final local = (await db.getData()).single.updatedAtMillis;

    final stale = makeTask('1', updatedAt: '${local - 1}');
    expect(await db.saveFromRemote(stale), isFalse);
    expect((await db.getData()).single.status, 'complete');

    final newer = makeTask('1', updatedAt: '${local + 1}');
    expect(await db.saveFromRemote(newer), isTrue);
    expect((await db.getData()).single.status, 'todo');
  });

  test('remoto sem updatedAt (versão antiga) ainda entra se não há local',
      () async {
    expect(await db.saveFromRemote(makeTask('9')), isTrue);
    expect((await db.getData()).single.key, '9');
  });

  test('requeueAll recoloca tudo na fila (migração para nó por uid)', () async {
    await db.saveFromRemote(makeTask('1', updatedAt: '10'));
    await db.saveFromRemote(makeTask('2', updatedAt: '20'));
    expect(await db.getPendingUploads(), isEmpty);

    await db.requeueAll();

    expect(
        (await db.getPendingUploads()).map((t) => t.key).toSet(), {'1', '2'});
    expect(await db.getData(), hasLength(2));
  });

  test('migração v1 -> v2 preserva tasks e acrescenta updatedAt', () async {
    final legacy = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false));
    for (final table in ['Tasks', 'PendingUploads', 'PendingDeletes']) {
      // schema original da v1, com o typo `status,TEXT`
      await legacy.execute(
          'CREATE TABLE $table(key TEXT PRIMARY KEY,title TEXT,category TEXT,description TEXT,image TEXT,date TEXT,time,periority TEXT,show TEXT,progress TEXT,status,TEXT)');
    }
    await legacy
        .insert('Tasks', {'key': 'old', 'title': 'antiga', 'status': 'todo'});
    await legacy.insert('PendingUploads', {'key': 'off', 'title': 'offline'});

    await DbHelper.upgradeSchema(legacy, 1, DbHelper.schemaVersion);
    await DbHelper.useDatabase(legacy);

    final all = await db.getData();
    expect(all.map((t) => t.key).toSet(), {'old', 'off'});
    expect(all.every((t) => t.updatedAtMillis == 0), isTrue);

    await db.update(makeTask('old', status: 'complete'));
    expect((await db.getPendingUploads()).map((t) => t.key).toSet(),
        {'off', 'old'});
    await legacy.close();
  });
}
