import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:to_do_app/data/network/firebase/firebase_services.dart';
import 'package:to_do_app/data/notifications/notification_service.dart';
import 'package:to_do_app/data/sync/task_sync.dart';
import 'package:to_do_app/data/shared%20pref/shared_pref.dart';
import 'package:to_do_app/utils/utils.dart';
import 'package:to_do_app/view%20model/DbHelper/db_helper.dart';
import 'package:to_do_app/view/home%20page/components/status_update_sheet.dart';
import '../../model/task_filter.dart';
import '../../model/task_model.dart';
import '../../model/task_status.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  RxMap userData = {}.obs;
  RxString name = ''.obs;
  RxBool focus = false.obs;
  RxBool hasText = false.obs;
  RxInt taskCount = 0.obs;
  RxBool hasData = false.obs;
  final DbHelper db = DbHelper();
  // retryBase liga o reenvio automático com backoff quando o envio falha
  late final TaskSync sync = TaskSync(db, FirebaseTaskRemote(),
      retryBase: const Duration(seconds: 5),
      logger: (message) => debugPrint('[TaskSync] $message'));
  // estado de sincronização, para a UI mostrar "pendente"/"falhou" se quiser
  RxInt pendingCount = 0.obs;
  RxBool syncFailed = false.obs;
  final List<StreamSubscription<dynamic>> _subs = [];
  // eventos remotos são aplicados um por vez, na ordem em que chegaram
  Future<void> _remoteChain = Future.value();
  RxList list = [].obs;
  Connectivity? connectivity;
  final searchController = TextEditingController().obs;
  // filtros da home: prioridade (All/High/Medium/Low) e status (All/Pending/Completed)
  RxString priorityFilter = 'All'.obs;
  RxString statusFilter = 'All'.obs;
  // espelho reativo do texto de busca (TextEditingController não é reativo p/ Obx)
  RxString searchQuery = ''.obs;
  // Os efeitos colaterais ficam em onInit (e não no construtor): os widgets
  // fazem `Get.put(HomeController())`, e o Dart executa o construtor ANTES do
  // put, mesmo quando já existe uma instância registrada. No construtor, cada
  // chamada deixaria listeners e um TaskSync órfãos rodando em paralelo.
  // onInit só roda na instância que o Get realmente registra.
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    getUserData();
    _startSync();
    getTaskData();
  }

  /// Ao voltar para o app, tenta enviar o que ficou pendente: timers e
  /// listeners de rede nem sempre rodam enquanto o app está em segundo plano.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) syncPending();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final sub in _subs) {
      sub.cancel();
    }
    _subs.clear();
    sync.dispose();
    super.onClose();
  }

  Future<void> _startSync() async {
    try {
      final user = FirebaseService.auth.currentUser;
      if (user == null) {
        // sessão do Firebase perdida: o app segue funcionando local e a fila
        // espera o próximo login, em vez de quebrar na abertura
        debugPrint('Sem usuário autenticado: sync remoto desligado');
        return;
      }
      await _migrateToUidNode(user.uid);
      if (isClosed)
        return; // fechou enquanto migrava: não deixa listeners órfãos
      final tasksRef = FirebaseDatabase.instance.ref('Tasks').child(user.uid);

      // traz do Firebase o que mudou em outro aparelho (inclusive enquanto o
      // app estava fechado); alteração local ainda não enviada sempre ganha
      _subs.add(tasksRef.onValue.listen((event) {
        _enqueueRemote(() async {
          for (final element in event.snapshot.children) {
            await db.saveFromRemote(_taskFromSnapshot(element));
          }
          getTaskData();
        });
      }, onError: _onRemoteError));

      // o snapshot do evento é a própria task alterada (não a lista)
      _subs.add(tasksRef.onChildChanged.listen((event) {
        _enqueueRemote(() async {
          await db.saveFromRemote(_taskFromSnapshot(event.snapshot));
          getTaskData();
        });
      }, onError: _onRemoteError));

      connectivity = Connectivity();
      // listener for internet state
      _subs.add(connectivity!.onConnectivityChanged.listen((results) {
        // connectivity_plus devolve a lista de conexões ativas (ex.: wifi + vpn)
        if (results.any((r) => r != ConnectivityResult.none)) syncPending();
      }));
      // o que ficou pendente de uma sessão anterior sobe já na abertura
      syncPending();
    } catch (e) {
      debugPrint('Sync remoto não iniciado: $e');
    }
  }

  /// As tasks ficavam em `Tasks/<parte-do-email>` (nó compartilhável entre
  /// contas com o mesmo prefixo). Agora ficam em `Tasks/<uid>`. Na primeira
  /// vez neste aparelho, tudo que existe local é recolocado na fila para subir
  /// ao novo nó; as tasks nunca ficam só no nó antigo.
  Future<void> _migrateToUidNode(String uid) async {
    if (await UserPref.isNodeMigrated(uid)) return;
    await db.requeueAll();
    await UserPref.markNodeMigrated(uid);
  }

  void _enqueueRemote(Future<void> Function() job) {
    _remoteChain = _remoteChain.then((_) => job()).catchError((Object e) {
      debugPrint('Evento remoto ignorado: $e');
    });
  }

  void _onRemoteError(Object error) {
    // ex.: permission-denied encerra o stream; local + fila seguem intactos
    debugPrint('Listener do Firebase falhou: $error');
    if (!isClosed) syncFailed.value = true;
  }

  static TaskModel _taskFromSnapshot(DataSnapshot snapshot) {
    String? field(String name) => snapshot.child(name).value?.toString();
    return TaskModel(
        key: field('key') ?? snapshot.key,
        time: field('time'),
        progress: field('progress'),
        status: field('status'),
        date: field('date'),
        periority: field('periority'),
        description: field('description'),
        category: field('category'),
        title: field('title'),
        image: field('image'),
        show: field('show'),
        updatedAt: field('updatedAt'));
  }

  /// Envia a fila local (criações, mudanças de status e remoções feitas
  /// offline). Itens só saem da fila depois que o Firebase confirmou.
  /// Falha "de verdade" para o usuário: erro que esperar não resolve, ou
  /// 3 tentativas seguidas sem sucesso. Antes disso é só "aguardando envio"
  /// (ex.: sem rede), que a nova tentativa automática resolve sozinha.
  bool get _hardFailure =>
      sync.lastErrorLooksPermanent || sync.consecutiveFailures >= 3;

  Future<bool> syncPending() async {
    final ok = await sync.run();
    await refreshPending();
    if (!isClosed) syncFailed.value = !ok && _hardFailure;
    return ok;
  }

  checkData() {
    int count = 0;
    for (int i = 0; i < list.length; i++) {
      if (list[i].show == 'yes') {
        count++;
      }
    }
    if (count > 0) {
      hasData.value = true;
      taskCount.value = count;
    } else {
      hasData.value = false;
      taskCount.value = 0;
    }
  }

  popupMenuSelected(int value, int index, BuildContext context) async {
    if (value == 1) {
      showStatusSheet(index);
    } else if (value == 2) {
      Utils.showWarningDailog(context, () => removeFromList(index));
    }
  }

  showStatusSheet(int index) {
    StatusUpdateSheet.show(
        initialStatus: TaskStatus.from(list[index]),
        onSave: (status) => updateStatus(index, status));
  }

  /// `status` é a fonte da verdade; `progress` continua sendo gravado derivado
  /// (0/50/100) para bases antigas que ainda leem o campo numérico.
  updateStatus(int index, TaskStatus status) async {
    final task = list[index];
    await db.update(TaskModel(
        key: task.key,
        status: status.storageValue,
        progress: status.progressText,
        time: task.time,
        date: task.date,
        periority: task.periority,
        description: task.description,
        category: task.category,
        title: task.title,
        image: task.image,
        show: task.show));
    // offline first: grava local + fila; o Firebase recebe quando der
    getTaskData();
    syncPending();
  }

  getTaskData() async {
    // pendentes também já estão em Tasks: a fila não entra na lista
    list.value = await db.getData();
    checkData();
    refreshPending();
  }

  /// Atualiza o contador de pendentes logo que algo muda no banco local, sem
  /// esperar o envio terminar (senão o aviso só apareceria depois da falha).
  Future<void> refreshPending() async {
    try {
      final pending = await db.pendingCount();
      if (!isClosed) pendingCount.value = pending;
    } catch (e) {
      debugPrint('Contagem de pendentes indisponível: $e');
    }
  }

  Future<List<TaskModel>> getFututeData() {
    return db.getData();
  }

  /// Lista que a UI consome: busca + prioridade + status sobre `list`.
  /// Lida dentro de Obx, reage a list/searchQuery/priorityFilter/statusFilter.
  List<TaskModel> get filteredTasks => TaskFilter.apply(
        list,
        query: searchQuery.value,
        priority: priorityFilter.value,
        status: statusFilter.value,
      );
  setPriorityFilter(String value) {
    priorityFilter.value = value;
  }

  setStatusFilter(String value) {
    statusFilter.value = value;
  }

  onClear(BuildContext context) {
    searchController.value.text = '';
    searchQuery.value = '';
    hasText.value = false;
    onTapOutside(context);
  }

  onTapOutside(BuildContext context) {
    focus.value = false;
    FocusScope.of(context).unfocus();
  }

  checkText() {
    searchQuery.value = searchController.value.text;
    hasText.value = searchController.value.text.toString().isNotEmpty;
  }

  onTapField() {
    focus.value = true;
  }

  getUserData() async {
    userData.value = await UserPref.getUser();
    getName();
  }

  getName() {
    final fullName = userData['NAME'].toString().trim();
    final spaceIndex = fullName.indexOf(' ');
    name.value = spaceIndex >= 0 ? fullName.substring(0, spaceIndex) : fullName;
  }

  removeFromList(int index) {
    NotificationService.cancelTaskReminder(list[index].key);
    db
        .removeFromList(TaskModel(
            key: list[index].key,
            status: list[index].status,
            progress: list[index].progress,
            time: list[index].time,
            date: list[index].date,
            periority: list[index].periority,
            description: list[index].description,
            category: list[index].category,
            title: list[index].title,
            image: list[index].image,
            show: 'no'))
        .then((value) {
      getTaskData();
      syncPending();
    });
  }
}
