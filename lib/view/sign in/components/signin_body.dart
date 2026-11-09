import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_app/res/routes/routes.dart';
import 'package:to_do_app/view%20model/controller/signin_controller.dart';
import 'package:to_do_app/view/sign%20in/components/signin_bar.dart';
import 'package:to_do_app/view/sign%20in/components/signin_input_form.dart';
import '../../sign up/components/button.dart';
import '../../sign up/components/signup_options.dart';

class SignInBody extends StatelessWidget {
  SignInBody({super.key});
  final controller = Get.put(SignInController());
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 30,
            ),
            const SignInBar(),
            const SizedBox(
              height: 50,
            ),
            Text(
              'sign_in_options'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(
              height: 20,
            ),
            const SignUpOptions(),
            SignInForm(),
            Obx(
              () => AccountButton(
                text: 'sign_login_account'.tr,
                loading: controller.loading.value,
                onTap: () {
                  controller.loginAccount();
                },
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () => Get.toNamed(Routes.signUpScreen),
                  child: RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: '${'sign_no_account'.tr} ',
                        style: const TextStyle(
                          color: Colors.grey,
                        )),
                    TextSpan(
                        text: 'sign_sign_up'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                        ))
                  ])),
                ))
          ],
        ),
      ),
    );
  }
}
