import 'package:flutter/material.dart';

import '../../../res/app_color.dart';
import '../../../res/translations/common_tr.dart';

class PeriorityContainer extends StatelessWidget {
  final VoidCallback onTap;
  final bool focus;
  final String type;
  /// null = ocupa a largura dada pelo pai (ex.: dentro de um Expanded).
  final double? width;
  final double fontSize;
  const PeriorityContainer(
      {super.key,
      required this.onTap,
      required this.focus,
      required this.type,
      this.width = 73,
      this.fontSize = 14});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 43,
        width: width,
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: focus?  const LinearGradient(colors: [
              Colors.purpleAccent,
              Colors.pinkAccent
            ]) : null),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Container(
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: primaryColor),
            child: Text(
              // `type` é o valor interno persistido ('Low'/'Medium'/'High');
              // só a exibição é traduzida.
              trValue(type),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
