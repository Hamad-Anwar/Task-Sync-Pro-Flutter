import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_do_app/res/app_color.dart';
class Utils{


  static bool validateEmail(String email){
    return EmailValidator.validate(email);
  }
  static String extractFirebaseError(String error){
   return error.substring(error.indexOf(']')+1);
  }
  static void showSnackBar(String title,String message,Widget icon){
   Get.showSnackbar(
     GetSnackBar(
       backgroundColor: primaryColor.withOpacity(.4),
       title: title,
       isDismissible: true,
       duration: const Duration(milliseconds: 2000),
       icon: icon,
       message: message,
       snackPosition: SnackPosition.BOTTOM,
       borderRadius: 20,
       margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
       padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
       snackStyle: SnackStyle.GROUNDED,
       barBlur: 30,
     )
   );
  }
  static String formateDate(DateTime date){
    // Formato de ARMAZENAMENTO da task — fixo em en_US, independente do locale.
    String formattedDate = DateFormat('d MMM y', 'en_US').format(date);
    return formattedDate;
  }
  static String formatDate(){
    // Só exibição (header) — segue o locale atual do app.
    String formattedDate =
        DateFormat('EEEE, d', Get.locale?.toString()).format(DateTime.now());
    return formattedDate;
  }
  static Map<int,String> getImage(){
    return {
      1 : 'assets/images/back2.jpg',
      2 : 'assets/images/back3.jpg',
      3 : 'assets/images/back1.jpg',
    };
  }
  static String getDaysDiffirece(String dateString){
    // Parse do formato de ARMAZENAMENTO — fixo em en_US.
    DateFormat dateFormat = DateFormat('dd MMM yyyy', 'en_US');
    DateTime date = dateFormat.parse(dateString);
    DateTime now = DateTime.now();
    Duration difference = now.difference(date);
    return (-1 * difference.inDays).toString();

  }


  static Future<void> showWarningDailog(BuildContext context,VoidCallback onConfirm) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('task_remove_task'.tr),
          content: Text('task_remove_confirm'.tr),
          actions: [
            TextButton(
              child: Text('task_cancel'.tr),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('task_remove'.tr),
              onPressed: () {
                onConfirm();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }


}

