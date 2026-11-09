import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_app/view/common%20widgets/back_button.dart';
class SignInBar extends StatelessWidget {
  const SignInBar({super.key});

  @override
  Widget build(BuildContext context) {
    return  Row(
      children: [
        const CustomBackButton(),
        const SizedBox(
          width: 20,
        ),
        Text(
          'sign_sign_in'.tr,
          style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        )
      ],
    );
  }
}
