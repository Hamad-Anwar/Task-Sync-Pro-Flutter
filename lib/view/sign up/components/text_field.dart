import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:to_do_app/view%20model/controller/signin_controller.dart';
import 'package:to_do_app/view%20model/controller/signup_controller.dart';
import 'package:to_do_app/view/sign%20up/components/textfield_sufiix.dart';
import '../../../res/app_color.dart';

class InputField extends StatelessWidget {
  InputField(
      {super.key,
      required this.onTap,
      required this.focus,
      required this.hint,
      required this.controller,
      this.correct,
      required this.onChange,
      this.hideText,
      this.showPass,
      this.prefix
      });

  final bool focus;
  final String hint;
  final TextEditingController controller;
  final VoidCallback onTap;
  final VoidCallback onChange;
  final VoidCallback? showPass;
  final bool? hideText;
  final bool? correct;
  final Widget? prefix;
  final _signUpController = Get.put(SignupController());
  final _signInController = Get.put(SignInController());

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: focus
            ? const LinearGradient(colors: [
                Colors.purpleAccent,
                Colors.pink,
              ])
            : null,
      ),
      child: TextFormField(
        controller: controller,
        onTap: onTap,
        onTapOutside: (event) {
          _signUpController.onTapOutside(context);
          _signInController.onTapOutside(context);
        },
        onChanged: (value) {
          onChange();
        },
        obscureText: hideText ?? false,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          filled: true,
          prefixIcon: prefix,
          suffixIcon: hideText == null
              ? correct == true
                  ? const TextFieldSufix(
                      icon: Icons.done,
                    )
                  : null
              : _signUpController.password.value.text.toString().isNotEmpty
                  ? GestureDetector(
                      onTap: showPass,
                      child: hideText!
                          ? const TextFieldSufix(
                              icon: FontAwesomeIcons.eye,
                              size: 13,
                            )
                          : const TextFieldSufix(
                              icon: FontAwesomeIcons.eyeLowVision,
                              size: 13,
                            ),
                    )
                  : const SizedBox(),
          fillColor: primaryColor,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none),
          hoverColor: Colors.pinkAccent,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          hintText: hint,
          hintStyle: const TextStyle(
              color: Colors.grey, fontWeight: FontWeight.normal, fontSize: 12),
        ),
      ),
    );
  }
}
