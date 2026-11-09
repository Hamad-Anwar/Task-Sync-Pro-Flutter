import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:to_do_app/model/task_model.dart';
import 'package:to_do_app/res/translations/app_translations.dart';
import 'package:to_do_app/model/task_stats.dart';
import 'package:to_do_app/view/dashboard/components/completion_ring.dart';
import 'package:to_do_app/view/dashboard/components/completion_section.dart';
import 'package:to_do_app/view/dashboard/components/empty_dashboard.dart';
import 'package:to_do_app/view/dashboard/components/group_stat_row.dart';
import 'package:to_do_app/view/dashboard/components/group_stat_section.dart';
import 'package:to_do_app/view/dashboard/components/overdue_card.dart';
import 'package:to_do_app/view/dashboard/components/status_counters.dart';

/// Mesmo helper de task_stats_test.dart: defaults sensatos para os 11 campos
/// obrigatórios do TaskModel; sobrescreva só o que o caso exige.
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

/// Data fixa usada como "hoje" — mantém os testes determinísticos.
final DateTime kNow = DateTime(2026, 9, 10);

/// Envolve o componente numa árvore mínima com largura finita.
/// Sem a largura, componentes que usam Expanded/LayoutBuilder estouram em
/// constraint infinita e o erro seria de teste, não do componente.
/// GetMaterialApp com as translations em pt_BR: os componentes usam '.tr' e,
/// sem isso, renderizariam a própria chave em vez do texto esperado.
Widget wrap(Widget child, {double width = 390}) {
  return GetMaterialApp(
    translations: AppTranslations(),
    locale: const Locale('pt', 'BR'),
    home: Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  );
}

/// Renderiza e falha se a árvore lançou qualquer exceção (inclui overflow).
Future<void> pumpComponent(WidgetTester tester, Widget child,
    {double width = 390}) async {
  await tester.pumpWidget(wrap(child, width: width));
  expect(tester.takeException(), isNull);
}

void main() {
  group('CompletionRing', () {
    testWidgets('mostra a % arredondada e o rótulo', (tester) async {
      await pumpComponent(tester, const CompletionRing(percent: 75));

      expect(find.text('75%'), findsOneWidget);
      expect(find.text('concluído'), findsOneWidget);
    });

    testWidgets('0% renderiza sem exceção (arco vazio)', (tester) async {
      await pumpComponent(tester, const CompletionRing(percent: 0));

      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('100% renderiza sem exceção', (tester) async {
      await pumpComponent(tester, const CompletionRing(percent: 100));

      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('percent fora da faixa não quebra o desenho', (tester) async {
      await pumpComponent(tester, const CompletionRing(percent: 150));
      await pumpComponent(tester, const CompletionRing(percent: -10));
    });

    testWidgets('arredonda a fração para inteiro', (tester) async {
      // 1 de 3 -> 33,33% -> '33%'
      await pumpComponent(
        tester,
        const CompletionRing(percent: 100 / 3),
      );

      expect(find.text('33%'), findsOneWidget);
    });
  });

  group('CompletionSection', () {
    testWidgets('3 de 4 concluídas renderiza 75%', (tester) async {
      final stats = TaskStats.from([
        makeTask(key: '1', progress: '100'),
        makeTask(key: '2', progress: '100'),
        makeTask(key: '3', progress: '100'),
        makeTask(key: '4', progress: '0'),
      ], now: kNow);

      await pumpComponent(tester, CompletionSection(stats: stats));

      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('0 de 0 renderiza 0% sem exceção', (tester) async {
      final stats = TaskStats.from([], now: kNow);

      await pumpComponent(tester, CompletionSection(stats: stats));

      expect(find.text('0%'), findsOneWidget);
      expect(find.text('0'), findsNWidgets(3));
    });

    testWidgets('leva os contadores de estado junto do anel', (tester) async {
      final stats = TaskStats.from([
        makeTask(key: '1', progress: '100'),
        makeTask(key: '2', progress: '50'),
        makeTask(key: '3', progress: '50'),
        makeTask(key: '4', progress: '0'),
      ], now: kNow);

      await pumpComponent(tester, CompletionSection(stats: stats));

      expect(find.text('25%'), findsOneWidget);
      expect(find.byType(CompletionRing), findsOneWidget);
      expect(find.byType(StatusCounters), findsOneWidget);
      expect(find.text('Concluídas'), findsOneWidget);
      expect(find.text('Em andamento'), findsOneWidget);
      expect(find.text('Não iniciadas'), findsOneWidget);
    });
  });

  group('StatusCounters', () {
    testWidgets('mostra os três números com seus rótulos', (tester) async {
      await pumpComponent(
        tester,
        const StatusCounters(completed: 7, inProgress: 3, notStarted: 5),
      );

      expect(find.text('7'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('Concluídas'), findsOneWidget);
      expect(find.text('Em andamento'), findsOneWidget);
      expect(find.text('Não iniciadas'), findsOneWidget);
    });

    testWidgets('tudo zerado mostra três zeros', (tester) async {
      await pumpComponent(
        tester,
        const StatusCounters(completed: 0, inProgress: 0, notStarted: 0),
      );

      expect(find.text('0'), findsNWidgets(3));
    });

    testWidgets('números grandes não estouram a largura', (tester) async {
      await pumpComponent(
        tester,
        const StatusCounters(
          completed: 12345,
          inProgress: 67890,
          notStarted: 24680,
        ),
        width: 320,
      );

      expect(find.text('12345'), findsOneWidget);
    });
  });

  group('GroupStatRow', () {
    testWidgets('mostra label e o texto X/Y (Z%)', (tester) async {
      await pumpComponent(
        tester,
        const GroupStatRow(
          stat: GroupStat(label: 'Work', total: 4, completed: 3),
        ),
      );

      expect(find.text('Work'), findsOneWidget);
      expect(find.text('3/4 (75%)'), findsOneWidget);
    });

    testWidgets('grupo sem nenhuma concluída mostra 0%', (tester) async {
      await pumpComponent(
        tester,
        const GroupStatRow(
          stat: GroupStat(label: 'Home', total: 5, completed: 0),
        ),
      );

      expect(find.text('0/5 (0%)'), findsOneWidget);
    });

    testWidgets('grupo vazio (0/0) não divide por zero', (tester) async {
      await pumpComponent(
        tester,
        const GroupStatRow(
          stat: GroupStat(label: 'Vazio', total: 0, completed: 0),
        ),
      );

      expect(find.text('0/0 (0%)'), findsOneWidget);
    });

    testWidgets('label muito longo é truncado sem overflow', (tester) async {
      await pumpComponent(
        tester,
        GroupStatRow(
          stat: GroupStat(
            label: 'Categoria com um nome absurdamente longo ' * 4,
            total: 10,
            completed: 10,
          ),
        ),
        width: 300,
      );

      expect(find.text('10/10 (100%)'), findsOneWidget);
    });
  });

  group('GroupStatSection', () {
    testWidgets('renderiza título e uma linha por grupo', (tester) async {
      final stats = TaskStats.from([
        makeTask(key: '1', category: 'Work', progress: '100'),
        makeTask(key: '2', category: 'Work', progress: '0'),
        makeTask(key: '3', category: 'Home', progress: '100'),
      ], now: kNow);

      await pumpComponent(
        tester,
        GroupStatSection(
          title: 'Por categoria',
          stats: stats.byCategory,
          emptyMessage: 'Sem categorias ainda',
        ),
      );

      expect(find.text('Por categoria'), findsOneWidget);
      expect(find.byType(GroupStatRow), findsNWidgets(2));
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('1/2 (50%)'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('1/1 (100%)'), findsOneWidget);
      expect(find.text('Sem categorias ainda'), findsNothing);
    });

    testWidgets('lista vazia mostra a mensagem própria', (tester) async {
      await pumpComponent(
        tester,
        const GroupStatSection(
          title: 'Por prioridade',
          stats: [],
          emptyMessage: 'Sem prioridades ainda',
        ),
      );

      expect(find.text('Por prioridade'), findsOneWidget);
      expect(find.text('Sem prioridades ainda'), findsOneWidget);
      expect(find.byType(GroupStatRow), findsNothing);
    });

    testWidgets('muitos grupos renderizam todos sem overflow', (tester) async {
      final stats = TaskStats.from([
        for (var i = 0; i < 12; i++)
          makeTask(key: '$i', category: 'Cat $i', progress: '100'),
      ], now: kNow);

      await pumpComponent(
        tester,
        GroupStatSection(
          title: 'Por categoria',
          stats: stats.byCategory,
          emptyMessage: 'Sem categorias ainda',
        ),
      );

      expect(find.byType(GroupStatRow), findsNWidgets(12));
    });
  });

  group('OverdueCard', () {
    testWidgets('zero atrasadas mostra o estado positivo', (tester) async {
      await pumpComponent(tester, const OverdueCard(overdue: 0));

      expect(find.text('Atrasadas'), findsOneWidget);
      expect(find.text('Nenhuma task atrasada'), findsOneWidget);
      expect(find.text('Tudo em dia por aqui'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    });

    testWidgets('uma atrasada usa o singular', (tester) async {
      await pumpComponent(tester, const OverdueCard(overdue: 1));

      expect(find.text('1 task atrasada'), findsOneWidget);
      expect(find.text('Passaram do prazo e ainda não foram concluídas'),
          findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsNothing);
    });

    testWidgets('duas ou mais usam o plural', (tester) async {
      await pumpComponent(tester, const OverdueCard(overdue: 2));
      expect(find.text('2 tasks atrasadas'), findsOneWidget);

      await pumpComponent(tester, const OverdueCard(overdue: 137));
      expect(find.text('137 tasks atrasadas'), findsOneWidget);
    });

    testWidgets('contagem vem de TaskStats sem tocar em banco', (tester) async {
      final stats = TaskStats.from([
        makeTask(key: '1', date: '1 Sep 2026', progress: '0'),
        makeTask(key: '2', date: '1 Sep 2026', progress: '50'),
        makeTask(key: '3', date: '30 Sep 2026', progress: '0'),
      ], now: kNow);

      await pumpComponent(tester, OverdueCard(overdue: stats.overdue));

      expect(find.text('2 tasks atrasadas'), findsOneWidget);
    });

    testWidgets('não estoura em tela estreita', (tester) async {
      await pumpComponent(tester, const OverdueCard(overdue: 99), width: 280);

      expect(find.text('99 tasks atrasadas'), findsOneWidget);
    });
  });

  group('EmptyDashboard', () {
    testWidgets('renderiza a mensagem de estado vazio', (tester) async {
      await pumpComponent(tester, const EmptyDashboard());

      expect(find.text('Nada para mostrar ainda'), findsOneWidget);
      expect(
        find.text(
          'Crie sua primeira task e o dashboard começa a acompanhar seu progresso.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.insights_rounded), findsOneWidget);
    });

    testWidgets('não estoura em tela estreita', (tester) async {
      await pumpComponent(tester, const EmptyDashboard(), width: 280);

      expect(find.text('Nada para mostrar ainda'), findsOneWidget);
    });
  });

  group('regressão de layout', () {
    /// Uma passada única por todos os componentes em larguras diferentes:
    /// qualquer overflow ou exceção de render derruba o teste.
    testWidgets('todos os componentes rendem limpos em várias larguras',
        (tester) async {
      final stats = TaskStats.from([
        makeTask(key: '1', category: 'Work', periority: 'High', progress: '100'),
        makeTask(key: '2', category: 'Work', periority: 'Low', progress: '50'),
        makeTask(key: '3', category: 'Home', periority: 'Low', progress: '0'),
      ], now: kNow);

      final componentes = <Widget>[
        CompletionSection(stats: stats),
        CompletionRing(percent: stats.completionPercent),
        StatusCounters(
          completed: stats.completed,
          inProgress: stats.inProgress,
          notStarted: stats.notStarted,
        ),
        GroupStatSection(
          title: 'Por categoria',
          stats: stats.byCategory,
          emptyMessage: 'Sem categorias ainda',
        ),
        GroupStatSection(
          title: 'Por prioridade',
          stats: stats.byPriority,
          emptyMessage: 'Sem prioridades ainda',
        ),
        GroupStatRow(stat: stats.byCategory.first),
        OverdueCard(overdue: stats.overdue),
        const EmptyDashboard(),
      ];

      for (final largura in const [280.0, 390.0, 600.0]) {
        for (final componente in componentes) {
          await pumpComponent(tester, componente, width: largura);
        }
      }
    });
  });
}
