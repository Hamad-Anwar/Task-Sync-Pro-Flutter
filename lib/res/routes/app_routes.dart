import 'package:get/get.dart';
import 'package:to_do_app/res/routes/routes.dart';
import 'package:to_do_app/view/home%20page/home_page.dart';
import 'package:to_do_app/view/sign%20in/sign_in.dart';
import 'package:to_do_app/view/sign%20up/sign_up.dart';
import 'package:to_do_app/view/splash/splash_screen.dart';

class AppRoutes{
  static List<GetPage> routes(){
    return [
      GetPage(name: Routes.splashScreen, page: ()=>const SplashScreen()),
      GetPage(name: Routes.signUpScreen, page: ()=>const SignUp()),
      GetPage(name: Routes.signInScreen, page: ()=>const SignIn()),
      GetPage(name: Routes.homePage, page: ()=> HomePage()),
    ];
  }
}