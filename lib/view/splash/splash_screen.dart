import 'package:flutter/material.dart';
import 'package:to_do_app/res/assets/app_images.dart';
import '../../res/app_color.dart';
import '../../view model/services/splash_services.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SplashServices.checkLogin();
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: black,
      body: Center(
        child: Container(
          alignment: Alignment.center,
          height: 150,
          width: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: primaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(.2),
                offset: const Offset(1, 1)
              ),
              BoxShadow(
                  color: Colors.grey.withOpacity(.2),
                  offset: const Offset(-1, -1)
              )
            ]
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.asset(AppImage.splash),
          )
        ),
      ),
    );
  }
}
