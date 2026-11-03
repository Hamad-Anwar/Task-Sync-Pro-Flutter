import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:to_do_app/res/translations/app_translations.dart';
import 'package:to_do_app/view/home%20page/components/sync_status_badge.dart';

Widget wrap(Widget child) => GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('pt', 'BR'),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('fica oculto quando tudo foi enviado', (tester) async {
    await tester
        .pumpWidget(wrap(const SyncStatusBadge(pending: 0, failed: false)));

    expect(find.byType(Icon), findsNothing);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('mostra quantas alterações faltam enviar', (tester) async {
    await tester
        .pumpWidget(wrap(const SyncStatusBadge(pending: 3, failed: false)));

    expect(find.text('Alterações a enviar: 3'), findsOneWidget);
    expect(find.byIcon(Icons.sync), findsOneWidget);
  });

  testWidgets('falha aparece e o toque tenta de novo', (tester) async {
    var retries = 0;
    await tester.pumpWidget(wrap(SyncStatusBadge(
      pending: 2,
      failed: true,
      onRetry: () => retries++,
    )));

    expect(find.text('Falha ao sincronizar. Toque para tentar de novo'),
        findsOneWidget);
    expect(find.byIcon(Icons.cloud_off), findsOneWidget);

    await tester.tap(find.byType(SyncStatusBadge));
    expect(retries, 1);
  });
}
