import 'package:flutter/material.dart';

import '../../res/app_color.dart';

class CustomBackButton extends StatelessWidget {
  final double height;
  final double width;
  final double radius;
  final Widget widget;
  const CustomBackButton({super.key,this.width=40,this.height=40,this.radius=12,this.widget=const Icon(
    Icons.arrow_back_ios_new_rounded,
    color: Colors.white70,
    size: 18,
  )});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: black,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(.2),
                offset: const Offset(1, 0)),
            BoxShadow(
                color: Colors.grey.withOpacity(.2),
                offset: const Offset(0, 1)),
            BoxShadow(
                color: Colors.grey.withOpacity(.2),
                offset: const Offset(-1, 0)),
            BoxShadow(
                color: Colors.grey.withOpacity(.2),
                offset: const Offset(0, -1)),
          ]),
      child: widget,
    );
  }
}
