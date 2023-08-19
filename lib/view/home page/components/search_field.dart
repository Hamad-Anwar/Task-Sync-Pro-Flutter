
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:to_do_app/view%20model/controller/home_controller.dart';

import '../../../res/app_color.dart';
import '../../../res/assets/app_icons.dart';
import '../../sign up/components/textfield_sufiix.dart';

class SearchField extends StatelessWidget {
   SearchField({super.key});
  final controller=Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      margin: EdgeInsets.symmetric(horizontal: 20),
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: controller.focus.value
            ? const LinearGradient(colors: [
          Colors.purpleAccent,
          Colors.pink,
        ])
            : null,
      ),
      child: TextFormField(
        controller: controller.searchController.value,
        onTap:controller.onTapField,
        onTapOutside: (event) {
          controller.onTapOutside(context);
        },
        onChanged: (value) {
          controller.checkText();
        },
        style:
        const TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          filled: true,
          prefixIcon: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
            child: SvgPicture.asset(AppIcon.search,height: 20,width: 20,color: Colors.grey,),
          ),
          suffixIcon:  Obx(()=> controller.hasText.value ?GestureDetector(
            onTap: () => controller.onClear(context),
            child: const TextFieldSufix(
              icon: Icons.clear,),
          ): const SizedBox() ),
          fillColor: primaryColor,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none),
          hoverColor: Colors.pinkAccent,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          hintText: 'Search ...',
          hintStyle: const TextStyle(
              color: Colors.grey, fontWeight: FontWeight.normal, fontSize: 12),
        ),
      ),
    );
  }
}