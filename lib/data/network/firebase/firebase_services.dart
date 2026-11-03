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

  /// Chave do nó a partir do email: parte antes do @, sem os caracteres
  /// proibidos em paths do Realtime Database (. # $ [ ])
  static String nodeFromEmail(String email) {
    final at = email.indexOf('@');
    final local = at >= 0 ? email.substring(0, at) : email;
    return local.replaceAll(RegExp(r'[.#$\[\]]'), '_');
  }

  /// Snackbar padrão das falhas do Firebase: título "Error", mensagem sem o
  /// prefixo [plugin/codigo] e ícone de alerta vermelho.
  static void showFirebaseError(Object? error) {
    Utils.showSnackBar(
        'Error',
        Utils.extractFirebaseError(error.toString()),
        const Icon(
          FontAwesomeIcons.triangleExclamation,
          color: Colors.red,
        ));
  }

  /// Grava a task inteira no Firebase. Completa só quando o servidor
  /// confirmou e propaga o erro — quem chama decide se tira da fila.
  static Future<void> insertData(TaskModel model) {
    String str = auth.currentUser!.email.toString();
    String node = nodeFromEmail(str);
    return database.ref('Tasks').child(node).child(model.key!).set({
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
    });
  }

  static Future<void> createAccount() async {
    try {
      signUpController.setLoading(true);
      final String str = signUpController.email.value.text.toString();
      final String node = nodeFromEmail(str);
      database.ref('Accounts').child(node).set({
        'name': '${signUpController.name.value.text} ',
        'email': signUpController.email.value.text.toString(),
        'password': signUpController.password.value.text.toString(),
      }).then((value) {
        auth
            .createUserWithEmailAndPassword(
                email: signUpController.email.value.text.toString(),
                password: signUpController.password.value.text.toString())
            .then((value) {
          UserPref.setUser(
              '${signUpController.name.value.text} ',
              signUpController.email.value.text.toString(),
              signUpController.password.value.text.toString(),
              node,
              value.user!.uid.toString());
          Utils.showSnackBar(
              'Sign up',
              "Account is successfully created",
              const Icon(
                Icons.done,
                color: Colors.white,
              ));
          Get.to(HomePage());
          signUpController.setLoading(false);
        }).onError((error, stackTrace) {
          showFirebaseError(error);
          signUpController.setLoading(false);
        });
      }).onError((error, stackTrace) {
        showFirebaseError(error);
        signUpController.setLoading(false);
      });
    } catch (e) {
      showFirebaseError(e);
      signUpController.setLoading(true);
    }
  }

  static Future<void> loginAccount() async {
    try {
      signInController.setLoading(true);
      auth
          .signInWithEmailAndPassword(
        email: signInController.email.value.text.toString(),
        password: signInController.password.value.text.toString(),
      )
          .then((value) {
        String node = nodeFromEmail(value.user!.email!);
        database.ref('Accounts').child(node).onValue.listen((event) {
          UserPref.setUser(
            event.snapshot.child('name').value.toString(),
            event.snapshot.child('email').value.toString(),
            event.snapshot.child('password').value.toString(),
            node,
            value.toString(),
          );
          Utils.showSnackBar(
              'Sign up',
              "Successfully Login.Welcome Back!",
              const Icon(
                Icons.done,
                color: Colors.white,
              ));
          Get.to(HomePage());
          signInController.setLoading(false);
        }).onError((error, stackTrace) {
          showFirebaseError(error);
          signInController.setLoading(false);
        });
      }).onError((error, stackTrace) {
        showFirebaseError(error);
        signInController.setLoading(false);
      });
    } catch (e) {
      showFirebaseError(e);
      signInController.setLoading(true);
    }
  }

  static Future<void> signInwWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      googleSignIn
          .signIn()
          .then((GoogleSignInAccount? googleSignInAccount) async {
        if (googleSignInAccount != null) {
          // Get the GoogleSignInAuthentication object
          final GoogleSignInAuthentication googleSignInAuthentication =
              await googleSignInAccount.authentication;
          // Create an AuthCredential object
          final AuthCredential credential = GoogleAuthProvider.credential(
            idToken: googleSignInAuthentication.idToken,
            accessToken: googleSignInAuthentication.accessToken,
          );

          await auth.signInWithCredential(credential).then((value) {
            final String str = value.user!.email.toString();
            final String node = nodeFromEmail(str);
            database.ref('Accounts').child(node).set({
              'name': value.user!.displayName,
              'email': value.user!.email,
            }).then((val) {
              Utils.showSnackBar(
                  'Login',
                  'Successfully Login',
                  const Icon(
                    FontAwesomeIcons.triangleExclamation,
                    color: Colors.red,
                  ));
              UserPref.setUser(value.user!.displayName!, value.user!.email!,
                  "NOPASSWORD", node, value.user!.uid);
            }).onError((error, stackTrace) {
              showFirebaseError(error);
              return;
            });
          }).onError((error, stackTrace) {
            showFirebaseError(error);
            return;
          });
        }
      }).onError((error, stackTrace) {
        showFirebaseError(error);
        return;
      });
    } catch (e) {
      showFirebaseError(e);
    }
  }

  static Future<void> signInWithApple() async {}
  static Future<int> childCount() async {
    String str = auth.currentUser!.email.toString();
    String node = nodeFromEmail(str);
    return database.ref('Tasks').child(node).once().then((value) {
      return value.snapshot.children.length;
    });
  }

  static Future<void> update(String key, String updateKey, String updateValue) {
    String str = auth.currentUser!.email.toString();
    String node = nodeFromEmail(str);
    return database
        .ref('Tasks')
        .child(node)
        .child(key)
        .update({updateKey: updateValue});
  }
}

class FirebaseTaskRemote implements TaskRemote {
  @override
  Future<void> push(TaskModel task) => FirebaseService.insertData(task);

  @override
  Future<void> hide(String key) => FirebaseService.update(key, 'show', 'no');
}
