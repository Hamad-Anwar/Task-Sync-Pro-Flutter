import 'package:flutter/material.dart';
class ImageContainer extends StatelessWidget {
  final String image;
  final VoidCallback onTap;
  final bool focus;
  const ImageContainer({super.key, required this.image, required this.onTap, required this.focus});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        width: 100,
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: focus? LinearGradient(colors: [
              Colors.purpleAccent,
              Colors.pinkAccent,
            ]): null),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            image,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
