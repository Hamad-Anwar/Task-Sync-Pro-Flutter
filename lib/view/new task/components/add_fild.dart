import 'package:flutter/material.dart';
import '../../../res/app_color.dart';

class AddInputField extends StatelessWidget {
  final bool focus;
  final VoidCallback onTap;
  final VoidCallback onTapOutSide;
  final String hint;
  final double? width;
  final TextEditingController? controller;

  const AddInputField(
      {super.key,
      required this.focus,
      required this.onTap,
      required this.onTapOutSide,
      required this.hint,
      required this.width,
      this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: width,
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
          FocusScope.of(context).unfocus();
          onTapOutSide();
        },
        onChanged: (value) {},
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          filled: true,
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
