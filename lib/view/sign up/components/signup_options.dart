import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:to_do_app/Data/network/firebase/firebase_services.dart';

import 'icon_container.dart';

class SignUpOptions extends StatelessWidget {
  const SignUpOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return   Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => FirebaseService.signInwWithGoogle(),
          child: const IconContainer(
              widget: Icon(
              FontAwesomeIcons.google,
                size: 18,
                color: Colors.white,
              )),
        ),
        const IconContainer(
            widget: Icon(
              Icons.apple_rounded,
              color: Colors.white,
            )),
      ],
    );
  }
}
