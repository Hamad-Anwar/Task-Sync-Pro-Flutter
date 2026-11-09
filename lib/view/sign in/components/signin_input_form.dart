import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_app/view%20model/controller/signin_controller.dart';

import '../../sign up/components/text_field.dart';

class SignInForm extends StatelessWidget {
   SignInForm({super.key});
  final controller=Get.put(SignInController());
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 40,
        ),
        Text(
          '  ${'sign_email'.tr}',
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 17),
        ),
        const SizedBox(
          height: 10,
        ),
        Obx(() => InputField(
          onTap: () => controller.onFocusEmail(),
          focus: controller.emailFocus.value,
          hint: 'sign_email_hint'.tr,
          controller: controller.email.value,
          correct: controller.correctEmail.value,
          onChange: controller.validateEmail,
        )),
        const SizedBox(
          height: 20,
        ),
        Text(
          '  ${'sign_password'.tr}',
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 17),
        ),
        const SizedBox(
          height: 10,
        ),
        Obx(
              () => InputField(
            onTap: () => controller.onFocusPassword(),
            focus: controller.passwordFocus.value,
            hint: 'sign_password_hint'.tr,
            controller: controller.password.value,
            hideText: controller.showPassword.value,
            onChange: () {
            },
            showPass: () => controller.showPassword.toggle(),
          ),
        ),
        const SizedBox(
          height: 40,
        ),
      ],
    );
  }
}
