import 'package:flutter/material.dart';
import '../../../res/app_color.dart';

class DateTimeContainer extends StatelessWidget {
  final String text;
  final Widget icon;
  final VoidCallback onTap;
  const DateTimeContainer({super.key, required this.text, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    var size=MediaQuery.sizeOf(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        width: size.width / 2.5,
        decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon,
            // Icon(
            //   FontAwesomeIcons.calendar,
            //   color: Colors.white24,
            //   size: 20,
            // ),
            const SizedBox(
              width: 10,
            ),
            Text(
              text,
              style:
              const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
