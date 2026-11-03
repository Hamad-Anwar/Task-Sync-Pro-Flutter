import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:to_do_app/data/shared%20pref/shared_pref.dart';
import 'package:to_do_app/data/sync/task_sync.dart';
import 'package:to_do_app/model/task_model.dart';
import 'package:to_do_app/utils/utils.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:to_do_app/view%20model/controller/signin_controller.dart';
import 'package:to_do_app/view/home%20page/home_page.dart';
import '../../../view model/controller/signup_controller.dart';

class FirebaseService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseDatabase database = FirebaseDatabase.instance;
  static final signInController = Get.put(SignInController());
  static final signUpController = Get.put(SignupController());

  /// Tempo máximo para operações auxiliares (perfil do usuário) que não podem
  /// travar o login quando a rede está lenta.
  static const Duration _profileTimeout = Duration(seconds: 8);

  /// LEGADO: o nó das tasks era derivado do email (parte antes do @), então
  /// `joao@gmail.com` e `joao@outlook.com` dividiam as mesmas tasks. Hoje o nó
  /// é o `uid` (ver [userNode]); isto só existe para referência/migração.
  static String nodeFromEmail(String email) {
    final at = email.indexOf('@');
    final local = at >= 0 ? email.substring(0, at) : email;
    return local.replaceAll(RegExp(r'[.#$\[\]]'), '_');
  }

  /// Nó das tasks do usuário logado: o `uid`, único e imutável por conta.
  /// Lança [StateError] sem sessão — a task segue na fila local até haver login.
  static String userNode() {
    final user = auth.currentUser;
    if (user == null) throw StateError('Sem usuário autenticado');
    return user.uid;
  }

  /// Grava a task inteira no Firebase. Completa só quando o servidor
  /// confirmou e propaga o erro — quem chama decide se tira da fila.
  ///
  /// Usa transação para respeitar o `updatedAt`: se o servidor já tem uma
  /// versão mais nova (outro aparelho editou depois), a escrita é descartada
  /// em vez de sobrescrevê-la. Descartar conta como sucesso: a versão remota
  /// chega ao app pelo listener e passa a valer localmente.
  static Future<void> insertData(TaskModel model) async {
    final ref = database.ref('Tasks').child(userNode()).child(model.key!);
    final data = {
      'key': model.key,
      'title': model.title,
      'description': model.description,
      'category': model.category,
      'date': model.date,
      'time': model.time,
      'image': model.image,
      'periority': model.periority,
      'show': model.show,
      'status': model.status,
      'progress': model.progress,
      'updatedAt': model.updatedAt,
    };
    final result = await ref.runTransaction((current) {
      if (TaskModel.updatedAtOf(current) > model.updatedAtMillis) {
        return Transaction.abort();
      }
      return Transaction.success(data);
    });
    if (!result.committed) {
      developer.log(
          'Task ${model.key}: servidor tem versão mais nova, envio descartado',
          name: 'FirebaseService');
    }
  }

  /// Perfil (nome/email) em `Users/<uid>`. Melhor esforço: o app funciona sem
  /// ele, então falha ou lentidão aqui nunca derruba cadastro/login.
  static Future<void> _saveProfile(User user, String name) async {
    try {
      await database.ref('Users').child(user.uid).update({
        'name': name,
        'email': user.email,
      }).timeout(_profileTimeout);
    } catch (e) {
      developer.log('Perfil não gravado: $e', name: 'FirebaseService');
    }
  }

  static Future<String> _profileName(User user) async {
    try {
      final snapshot = await database
          .ref('Users')
          .child(user.uid)
          .child('name')
          .get()
          .timeout(_profileTimeout);
      final name = snapshot.value?.toString().trim() ?? '';
      if (name.isNotEmpty) return name;
    } catch (e) {
      developer.log('Perfil não lido: $e', name: 'FirebaseService');
    }
    final saved = await UserPref.savedName();
    if (saved != null && saved.trim().isNotEmpty) return saved.trim();
    final display = user.displayName?.trim() ?? '';
    if (display.isNotEmpty) return display;
    return (user.email ?? '').split('@').first;
  }

  static void _showError(Object error) {
    Utils.showSnackBar(
        'Error',
        Utils.extractFirebaseError(error.toString()),
        const Icon(
          FontAwesomeIcons.triangleExclamation,
          color: Colors.red,
        ));
  }

  static Future<void> createAccount() async {
    try {
      signUpController.setLoading(true);
      final String name = signUpController.name.value.text.toString().trim();
      final String email = signUpController.email.value.text.toString();
      // a conta é criada primeiro: sem ela não há uid, e as regras do banco
      // só aceitam escrita de usuário autenticado
      final credential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: signUpController.password.value.text.toString());
      final user = credential.user!;
      await _saveProfile(user, name);
      await UserPref.setUser(name, email, user.uid);
      Utils.showSnackBar(
          'Sign up',
          "Account is successfully created",
          const Icon(
            Icons.done,
            color: Colors.white,
          ));
      Get.to(HomePage());
    } catch (e) {
      _showError(e);
    } finally {
      signUpController.setLoading(false);
    }
  }

  static Future<void> loginAccount() async {
    try {
      signInController.setLoading(true);
      final email = signInController.email.value.text.toString();
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: signInController.password.value.text.toString(),
      );
      final user = credential.user!;
      final name = await _profileName(user);
      await _saveProfile(user, name);
      await UserPref.setUser(name, user.email ?? email, user.uid);
      Utils.showSnackBar(
          'Login',
          "Successfully Login.Welcome Back!",
          const Icon(
            Icons.done,
            color: Colors.white,
          ));
      Get.to(HomePage());
    } catch (e) {
      _showError(e);
    } finally {
      signInController.setLoading(false);
    }
  }

  static Future<void> signInwWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await GoogleSignIn().signIn();
      if (account == null) return; // usuário cancelou
      final GoogleSignInAuthentication authentication =
          await account.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken,
      );
      final result = await auth.signInWithCredential(credential);
      final user = result.user!;
      final name = (user.displayName?.trim().isNotEmpty ?? false)
          ? user.displayName!.trim()
          : (user.email ?? '').split('@').first;
      await _saveProfile(user, name);
      await UserPref.setUser(name, user.email ?? '', user.uid);
      Utils.showSnackBar(
          'Login',
          'Successfully Login',
          const Icon(
            Icons.done,
            color: Colors.white,
          ));
      Get.to(HomePage());
    } catch (e) {
      _showError(e);
    }
  }

  static Future<void> signInWithApple() async {}

  static Future<int> childCount() async {
    final snapshot = await database.ref('Tasks').child(userNode()).once();
    return snapshot.snapshot.children.length;
  }

  static Future<void> update(String key, String updateKey, String updateValue) {
    try {
      return database
          .ref('Tasks')
          .child(userNode())
          .child(key)
          .update({updateKey: updateValue});
    } catch (e) {
      return Future.error(e);
    }
  }
}

class FirebaseTaskRemote implements TaskRemote {
  @override
  Future<void> push(TaskModel task) => FirebaseService.insertData(task);

  @override
  Future<void> hide(String key) => FirebaseService.update(key, 'show', 'no');
}
