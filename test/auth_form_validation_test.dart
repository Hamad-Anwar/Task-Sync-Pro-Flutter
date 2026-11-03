import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:to_do_app/view%20model/controller/signin_controller.dart';
import 'package:to_do_app/view%20model/controller/signup_controller.dart';

// Sem traduções carregadas, 'chave'.tr devolve a própria chave: os testes
// conferem as chaves, que são o que os controllers escolhem mostrar.

/// Abre o app vazio, executa [action] e deixa a animação do snackbar terminar.
Future<void> pumpAction(WidgetTester tester, VoidCallback action) async {
  await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
  action();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

/// Fecha os snackbars (duração de 2s) para não deixar timers pendentes.
Future<void> dismissSnackBars(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
  Get.reset();
}

/// O aviso de validação: título sign_warning, a mensagem e o ícone rosa.
void expectWarning(WidgetTester tester, String messageKey) {
  expect(find.text('sign_warning'), findsOneWidget);
  expect(find.text(messageKey), findsOneWidget);
  final icon = tester.widget<Icon>(find.byType(Icon));
  expect(icon.icon, FontAwesomeIcons.triangleExclamation);
  expect(icon.color, Colors.pink);
}

SignInController signIn({required String email, required String password}) {
  final c = SignInController();
  c.email.value.text = email;
  c.password.value.text = password;
  c.validateEmail();
  return c;
}

SignupController signUp({
  required String name,
  required String email,
  required String password,
}) {
  final c = SignupController();
  c.name.value.text = name;
  c.email.value.text = email;
  c.password.value.text = password;
  c.validateName();
  c.validateEmail();
  return c;
}

void main() {
  group('login: avisos de validação', () {
    testWidgets('email inválido mostra o aviso de email', (tester) async {
      final c = signIn(email: 'email-invalido', password: '123456');
      await pumpAction(tester, c.loginAccount);
      expectWarning(tester, 'sign_enter_correct_email');
      await dismissSnackBars(tester);
    });

    testWidgets('senha com 5 caracteres mostra o aviso de tamanho', (
      tester,
    ) async {
      final c = signIn(email: 'aluno@example.com', password: '12345');
      await pumpAction(tester, c.loginAccount);
      expectWarning(tester, 'sign_password_length');
      await dismissSnackBars(tester);
    });

    testWidgets('senha com 6 caracteres passa da validação', (tester) async {
      final c = signIn(email: 'aluno@example.com', password: '123456');
      await pumpAction(tester, c.loginAccount);
      expect(find.text('sign_password_length'), findsNothing);
      expect(find.text('sign_warning'), findsNothing);
      await dismissSnackBars(tester);
    });
  });

  group('cadastro: avisos de validação', () {
    testWidgets('nome curto mostra o aviso de nome', (tester) async {
      final c = signUp(
        name: 'Leon',
        email: 'aluno@example.com',
        password: '123456',
      );
      await pumpAction(tester, c.createAccount);
      expectWarning(tester, 'sign_enter_correct_name');
      await dismissSnackBars(tester);
    });

    testWidgets('email inválido mostra o aviso de email', (tester) async {
      final c = signUp(
        name: 'Leon Fagner',
        email: 'email-invalido',
        password: '123456',
      );
      await pumpAction(tester, c.createAccount);
      expectWarning(tester, 'sign_enter_correct_email');
      await dismissSnackBars(tester);
    });

    testWidgets('senha com 5 caracteres mostra o aviso de tamanho', (
      tester,
    ) async {
      final c = signUp(
        name: 'Leon Fagner',
        email: 'aluno@example.com',
        password: '12345',
      );
      await pumpAction(tester, c.createAccount);
      expectWarning(tester, 'sign_password_length');
      await dismissSnackBars(tester);
    });

    testWidgets('senha com 6 caracteres passa da validação', (tester) async {
      final c = signUp(
        name: 'Leon Fagner',
        email: 'aluno@example.com',
        password: '123456',
      );
      await pumpAction(tester, c.createAccount);
      expect(find.text('sign_password_length'), findsNothing);
      expect(find.text('sign_warning'), findsNothing);
      await dismissSnackBars(tester);
    });
  });
}
