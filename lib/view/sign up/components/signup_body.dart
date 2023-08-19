import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_app/res/routes/routes.dart';
import 'package:to_do_app/view%20model/controller/signup_controller.dart';
import 'package:to_do_app/view/sign%20in/sign_in.dart';
import 'package:to_do_app/view/sign%20up/components/signup_options.dart';

import 'appbar.dart';
import 'button.dart';
import 'input_form.dart';

class SignupBody extends StatelessWidget {
  SignupBody({super.key});

  final controller = Get.put(SignupController());

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
            const SignUpBar(),
            const SizedBox(
              height: 50,
            ),
            const Text(
              'Sign up with one of the following options.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(
              height: 20,
            ),
            const SignUpOptions(),
            InputForm(),
            Obx(
              () => AccountButton(
                text: "Create Account",
                loading: controller.loading.value,
                onTap: () {
                  controller.createAccount();
                },
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () => Get.toNamed(Routes.signInScreen),
                  child: RichText(
                      text: const TextSpan(children: [
                    TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(
                          color: Colors.grey,
                        )),
                    TextSpan(
                        text: 'Login',
                        style: TextStyle(
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
