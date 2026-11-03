import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/network/firebase/firebase_services.dart';
import '../../utils/form_validation.dart';
import '../../utils/utils.dart';

class SignInController extends GetxController {
  RxBool emailFocus = false.obs;
  RxBool passwordFocus = false.obs;
  RxBool correctEmail = false.obs;
  RxBool showPassword = true.obs;
  RxBool loading = false.obs;
  final email = TextEditingController().obs;
  final password = TextEditingController().obs;

  void loginAccount() {
    if (!correctEmail.value) {
      FormValidation.showWarning('sign_enter_correct_email');
      return;
    }
    if (password.value.text.toString().length <
        FormValidation.minPasswordLength) {
      FormValidation.showWarning('sign_password_length');
      return;
    }

    FirebaseService.loginAccount();
  }

  void setLoading(bool value) {
    loading.value = value;
  }

  void validateEmail() {
    correctEmail.value = Utils.validateEmail(email.value.text.toString());
  }

  void onFocusEmail() {
    emailFocus.value = true;
    passwordFocus.value = false;
  }

  void onFocusPassword() {
    emailFocus.value = false;
    passwordFocus.value = true;
  }

  void onTapOutside(BuildContext context) {
    emailFocus.value = false;
    passwordFocus.value = false;
    FocusScope.of(context).unfocus();
  }
}
