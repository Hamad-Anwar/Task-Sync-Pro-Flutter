import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_app/res/app_color.dart';
import 'package:to_do_app/view/new%20task/components/addtask_body.dart';

class NewTask {
  NewTask(Size size) {
    Get.bottomSheet(
        backgroundColor: black,
        isScrollControlled: true,
          TaskBody());

  }
}
