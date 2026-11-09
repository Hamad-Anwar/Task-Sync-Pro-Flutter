import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:to_do_app/data/network/firebase/firebase_services.dart';
import 'package:to_do_app/utils/utils.dart';

/// Erro no formato que o FirebaseException produz no toString().
const firebaseError =
    '[firebase_auth/email-already-in-use] The email address is already in use '
    'by another account.';

/// Abre o app vazio, executa [show] e deixa a animação do snackbar terminar.
Future<void> pumpSnackBar(WidgetTester tester, VoidCallback show) async {
  await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
  show();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

/// Fecha o snackbar (duração de 2s) para não deixar timers pendentes.
Future<void> dismissSnackBar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

void expectErrorSnackBar(WidgetTester tester) {
  expect(find.text('Error'), findsOneWidget);
  expect(
    find.text(
      ' The email address is already in use by another account.',
    ),
    findsOneWidget,
  );
  final icon = tester.widget<Icon>(find.byType(Icon));
  expect(icon.icon, FontAwesomeIcons.triangleExclamation);
  expect(icon.color, Colors.red);
}

void main() {
  group('Utils.extractFirebaseError', () {
    test('remove o prefixo [plugin/codigo] e mantém o resto da mensagem', () {
      expect(
        Utils.extractFirebaseError(firebaseError),
        ' The email address is already in use by another account.',
      );
    });

    test('mensagem sem prefixo volta inteira', () {
      expect(Utils.extractFirebaseError('Sem conexão'), 'Sem conexão');
    });
  });

  group('snackbar de erro do FirebaseService (comportamento atual)', () {
    testWidgets(
      'o bloco repetido mostra título Error, a mensagem extraída e o ícone '
      'de alerta vermelho',
      (tester) async {
        // Cópia exata do bloco repetido em firebase_services.dart
        await pumpSnackBar(
          tester,
          () => Utils.showSnackBar(
            'Error',
            Utils.extractFirebaseError(firebaseError.toString()),
            const Icon(
              FontAwesomeIcons.triangleExclamation,
              color: Colors.red,
            ),
          ),
        );

        expectErrorSnackBar(tester);
        await dismissSnackBar(tester);
      },
    );

    testWidgets(
      'FirebaseService.showFirebaseError mostra o mesmo snackbar do bloco '
      'repetido',
      (tester) async {
        await pumpSnackBar(
          tester,
          () => FirebaseService.showFirebaseError(firebaseError),
        );

        expectErrorSnackBar(tester);
        await dismissSnackBar(tester);
      },
    );
  });
}
