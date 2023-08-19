import 'package:flutter/material.dart';
import 'package:to_do_app/view/sign%20in/components/signin_body.dart';

import '../../res/app_color.dart';

class SignIn extends StatelessWidget {
  const SignIn({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      body: SafeArea(
        child: SignInBody(),
      ),
    );
  }
}
