import 'dart:async';
import 'dart:developer' as developer;

import 'package:to_do_app/model/task_model.dart';

/// Fila local de tasks que ainda não chegaram ao Firebase.
abstract class TaskLocalStore {
  Future<List<TaskModel>> getPendingUploads();
  Future<List<TaskModel>> getPendingDeletes();
  Future<void> removePendingUpload(TaskModel sent);
  Future<void> removePendingDelete(String key);
}

/// Destino remoto. Os métodos só completam quando o servidor confirmou.
abstract class TaskRemote {
  Future<void> push(TaskModel task);
  Future<void> hide(String key);
}

/// Esvazia a fila local enviando para o remoto.
///
/// Garantias:
/// * Um item só sai da fila depois que o envio dele completou. Falha ou
///   timeout (sem internet, Firebase fora) mantém tudo pendente — reenviar é
///   seguro, o push é um `set` idempotente da task inteira.
/// * Um item com erro não trava os demais: cada um é tentado isoladamente.
/// * Se algo mudou na fila durante o envio (edição do usuário, nova task, outra
///   chamada de [run]), a fila é processada de novo na mesma execução, em vez
///   de esperar o próximo gatilho externo.
/// * Se ainda sobrar pendência, e [retryBase] estiver definido, agenda nova
///   tentativa sozinha com backoff exponencial (até [retryMax]).
class TaskSync {
  final TaskLocalStore local;
  final TaskRemote remote;
  final Duration timeout;

  /// Primeiro intervalo do reenvio automático após falha. `null` desliga.
  final Duration? retryBase;
  final Duration retryMax;

  /// Para onde vão as mensagens de diagnóstico. Sem isso usa `dart:developer`
  /// (só aparece no DevTools); o app passa `debugPrint` para vê-las no terminal.
  final void Function(String message)? logger;

  TaskSync(
    this.local,
    this.remote, {
    this.timeout = const Duration(seconds: 15),
    this.retryBase,
    this.retryMax = const Duration(minutes: 5),
    this.logger,
  });

  void _log(String message) {
    final out = logger;
    if (out != null) {
      out(message);
    } else {
      developer.log(message, name: 'TaskSync');
    }
  }

  /// Teto de passadas por execução: evita laço infinito se a fila nunca esvaziar.
  static const int _maxPasses = 5;

  Completer<bool>? _active;
  bool _again = false;
  Timer? _retryTimer;
  bool _disposed = false;
  int _failures = 0;
  Object? _lastError;

  /// Falhas seguidas desde o último ciclo que esvaziou a fila.
  int get consecutiveFailures => _failures;

  /// Último erro de envio (útil para diagnóstico/UI). `null` após sucesso.
  Object? get lastError => _lastError;

  bool get isRunning => _active != null;

  /// O último erro indica algo que esperar não resolve (regras do banco
  /// recusando, sessão inválida), ao contrário de rede fora do ar.
  bool get lastErrorLooksPermanent {
    final text = _lastError?.toString().toLowerCase() ?? '';
    return text.contains('permission-denied') ||
        text.contains('permission_denied') ||
        text.contains('sem usuário autenticado');
  }

  /// Retorna true se a fila ficou vazia. Chamadas simultâneas reaproveitam a
  /// execução em andamento, que reprocessa a fila antes de terminar (assim
  /// uma alteração feita durante o envio não fica esquecida).
  Future<bool> run() {
    final active = _active;
    if (active != null) {
      _again = true;
      return active.future;
    }
    final completer = _active = Completer<bool>();
    _drain(completer);
    return completer.future;
  }

  Future<void> _drain(Completer<bool> completer) async {
    var done = false;
    try {
      for (var pass = 0; pass < _maxPasses; pass++) {
        _again = false;
        final ok = await _pass();
        final pending = await _hasPending();
        done = ok && !pending;
        // ok + pendente = algo mudou durante o envio: processa de novo
        if (!_again && !(ok && pending)) break;
      }
    } catch (e) {
      done = false;
      _lastError = e;
      _log('Falha ao ler a fila local: $e');
    }
    // sem await entre a última leitura de _again e aqui: nenhum run() se perde
    _active = null;
    _finish(done);
    completer.complete(done);
  }

  /// Uma passada pela fila. Retorna false se qualquer item falhou.
  Future<bool> _pass() async {
    var allOk = true;
    for (final task in await local.getPendingUploads()) {
      try {
        await remote.push(task).timeout(timeout);
        await local.removePendingUpload(task);
      } catch (e) {
        allOk = false;
        _lastError = e;
        _log('Envio da task ${task.key} falhou: $e');
      }
    }
    for (final task in await local.getPendingDeletes()) {
      try {
        await remote.hide(task.key!).timeout(timeout);
        await local.removePendingDelete(task.key!);
      } catch (e) {
        allOk = false;
        _lastError = e;
        _log('Remoção da task ${task.key} falhou: $e');
      }
    }
    return allOk;
  }

  Future<bool> _hasPending() async =>
      (await local.getPendingUploads()).isNotEmpty ||
      (await local.getPendingDeletes()).isNotEmpty;

  void _finish(bool done) {
    _retryTimer?.cancel();
    _retryTimer = null;
    if (done) {
      _failures = 0;
      _lastError = null;
      return;
    }
    _failures++;
    final base = retryBase;
    if (base == null || _disposed) return;
    final factor = 1 << (_failures - 1).clamp(0, 16);
    final next = base * factor;
    _retryTimer = Timer(next > retryMax ? retryMax : next, () {
      _retryTimer = null;
      if (!_disposed) unawaited(run());
    });
  }

  /// Cancela a nova tentativa agendada. Chamar ao fechar o controller.
  void dispose() {
    _disposed = true;
    _retryTimer?.cancel();
    _retryTimer = null;
  }
}
