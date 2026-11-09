import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:to_do_app/data/sync/task_sync.dart';
import 'package:to_do_app/model/task_model.dart';

/// Banco local (fonte da verdade da UI) + fila de envio para o Firebase.
///
/// Toda alteração grava primeiro em `Tasks` e depois enfileira a task inteira
/// em `PendingUploads` (outbox). Quem tira da fila é o [TaskSync], e só depois
/// que o Firebase confirmou a escrita — assim nada se perde se a conexão cair
/// no meio do caminho ou o app for fechado offline.
class DbHelper implements TaskLocalStore {
  // compartilhado: Home e AddTask criam instâncias próprias do helper
  static Database? _db;

  // abertura em andamento: chamadas simultâneas (listeners, sync, UI) esperam
  // a mesma abertura em vez de abrir e "recuperar" a fila várias vezes
  static Future<Database>? _opening;

  Future<Database?> get db async {
    final existing = _db;
    if (existing != null) return existing;
    return _opening ??= _open();
  }

  static Future<Database> _open() async {
    try {
      // Android grava no armazenamento externo do app; ele pode não existir
      // (null) — nesse caso cai para o diretório interno em vez de quebrar
      final Directory directory =
          (Platform.isAndroid ? await getExternalStorageDirectory() : null) ??
              await getApplicationSupportDirectory();
      final database = await openDatabase(join(directory.path, 'db'),
          version: schemaVersion, onCreate: (db, version) async {
        await createSchema(db);
      }, onUpgrade: upgradeSchema);
      await _recoverPendingUploads(database);
      _db = database;
      return database;
    } finally {
      _opening =
          null; // falha na abertura não fica "presa": próxima chamada tenta de novo
    }
  }

  /// v1: tabelas originais. v2: coluna `updatedAt` (resolução de conflito).
  static const int schemaVersion = 2;

  static const List<String> _tables = [
    'Tasks',
    'PendingUploads',
    'PendingDeletes'
  ];

  // Colunas sempre nomeadas nos INSERT ... SELECT: bancos criados pela v1 têm
  // uma coluna extra "TEXT" (typo antigo em `status,TEXT`) e a ordem física
  // das colunas difere entre bancos novos e migrados.
  static const String _columns =
      'key,title,category,description,image,date,time,periority,show,progress,status,updatedAt';

  static Future<void> createSchema(Database db) async {
    for (final table in _tables) {
      await db.execute(
          'CREATE TABLE $table(key TEXT PRIMARY KEY,title TEXT,category TEXT,description TEXT,image TEXT,date TEXT,time TEXT,periority TEXT,show TEXT,progress TEXT,status TEXT,updatedAt TEXT)');
    }
  }

  /// Migra bancos existentes sem apagar nada: só acrescenta a coluna nova.
  static Future<void> upgradeSchema(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      for (final table in _tables) {
        await db.execute('ALTER TABLE $table ADD COLUMN updatedAt TEXT');
      }
    }
  }

  /// Versões antigas guardavam a task criada offline SÓ em PendingUploads.
  /// Copia para Tasks o que estiver só na fila, para a lista não depender dela.
  static Future<void> _recoverPendingUploads(Database db) async {
    await db.execute(
        'INSERT OR IGNORE INTO Tasks($_columns) SELECT $_columns FROM PendingUploads');
  }

  /// Recoloca todas as tasks locais na fila de envio. Usado na migração para o
  /// nó por usuário (uid): o que só existia no nó antigo do Firebase sobe de novo.
  Future<void> requeueAll() async {
    var dbClient = await db;
    await dbClient!.execute(
        'INSERT OR REPLACE INTO PendingUploads($_columns) SELECT $_columns FROM Tasks');
  }

  // Carimbo estritamente crescente: duas edições no mesmo milissegundo (ou
  // relógio que andou para trás) não empatam nem invertem a ordem local.
  static int _lastStamp = 0;
  static String _nextStamp() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _lastStamp = now > _lastStamp ? now : _lastStamp + 1;
    return _lastStamp.toString();
  }

  /// Testes: usa um banco já aberto (ex.: sqflite_common_ffi em memória).
  @visibleForTesting
  static Future<void> useDatabase(Database? database) async {
    _db = database;
    if (database != null) await _recoverPendingUploads(database);
  }

  /// Grava uma task criada/alterada no app: local + fila de envio.
  Future<TaskModel> insert(TaskModel model) async {
    await _saveAndEnqueue(model);
    return model;
  }

  Future<void> update(TaskModel model) => _saveAndEnqueue(model);

  /// Remoção é lógica (show = 'no') e também vai para a fila.
  Future<void> removeFromList(TaskModel model) async {
    var dbClient = await db;
    final rows = await dbClient!
        .query('Tasks', where: 'key = ?', whereArgs: [model.key!]);
    final current = rows.isEmpty ? model : TaskModel.fromMap(rows.first);
    current.show = 'no';
    await _saveAndEnqueue(current);
  }

  Future<void> _saveAndEnqueue(TaskModel model) async {
    model.updatedAt = _nextStamp();
    var dbClient = await db;
    await dbClient!.transaction((txn) async {
      await txn.insert('Tasks', model.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.insert('PendingUploads', model.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  /// Task que veio do Firebase: grava só local, sem reenfileirar.
  /// * Alteração local ainda não enviada sempre ganha.
  /// * Se a cópia local já enviada é mais nova que a remota (`updatedAt`), a
  ///   remota é ignorada — dado velho não regride o que o usuário já fez.
  /// Retorna true se gravou.
  Future<bool> saveFromRemote(TaskModel model) async {
    var dbClient = await db;
    if (await isRowExists(model.key!, 'PendingUploads')) return false;
    final rows = await dbClient!
        .query('Tasks', where: 'key = ?', whereArgs: [model.key!]);
    if (rows.isNotEmpty &&
        TaskModel.fromMap(rows.first).updatedAtMillis > model.updatedAtMillis) {
      return false;
    }
    await dbClient.insert('Tasks', model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return true;
  }

  Future<int> delete(String id, String table) async {
    var dbClient = await db;
    return await dbClient!.delete(table, where: 'key = ?', whereArgs: [id]);
  }

  Future<List<TaskModel>> getData() async {
    var dbClient = await db;
    final List<Map<String, Object?>> queryResult =
        await dbClient!.query('Tasks');
    return queryResult.map((e) => TaskModel.fromMap(e)).toList();
  }

  @override
  Future<List<TaskModel>> getPendingUploads() async {
    var dbClient = await db;
    final List<Map<String, Object?>> queryResult =
        await dbClient!.query('PendingUploads');
    return queryResult.map((e) => TaskModel.fromMap(e)).toList();
  }

  /// Fila antiga de remoções (só existe em bases de versões anteriores).
  @override
  Future<List<TaskModel>> getPendingDeletes() async {
    var dbClient = await db;
    final List<Map<String, Object?>> queryResult =
        await dbClient!.query('PendingDeletes');
    return queryResult.map((e) => TaskModel.fromMap(e)).toList();
  }

  /// Tira da fila só se a linha ainda for a que foi enviada: se o usuário
  /// mexeu na task durante o envio, a versão nova continua pendente.
  @override
  Future<void> removePendingUpload(TaskModel sent) async {
    var dbClient = await db;
    await dbClient!.transaction((txn) async {
      final rows = await txn
          .query('PendingUploads', where: 'key = ?', whereArgs: [sent.key!]);
      if (rows.isEmpty) return;
      if (!mapEquals(TaskModel.fromMap(rows.first).toMap(), sent.toMap())) {
        return;
      }
      await txn
          .delete('PendingUploads', where: 'key = ?', whereArgs: [sent.key!]);
    });
  }

  @override
  Future<void> removePendingDelete(String key) async {
    await delete(key, 'PendingDeletes');
  }

  /// Quantas alterações ainda não chegaram ao Firebase.
  Future<int> pendingCount() async {
    final dbClient = await db;
    final uploads = Sqflite.firstIntValue(
            await dbClient!.rawQuery('SELECT COUNT(*) FROM PendingUploads')) ??
        0;
    final deletes = Sqflite.firstIntValue(
            await dbClient.rawQuery('SELECT COUNT(*) FROM PendingDeletes')) ??
        0;
    return uploads + deletes;
  }

  Future<bool> isRowExists(String id, String table) async {
    var dbClient = await db;
    var count = await dbClient!.query(table, where: 'key = ?', whereArgs: [id]);

    return count.isNotEmpty;
  }
}
