import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_app/view%20model/controller/add_task_controller.dart';
import 'package:to_do_app/view/common%20widgets/status_options.dart';

import '../../../res/app_color.dart';

/// Último passo da criação de task: escolher o status inicial e confirmar.
class StatusPicker {
  StatusPicker(BuildContext context) {
    final controller = Get.put(AddTaskController());
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: primaryColor,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Text(
                'task_set_status'.tr,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: StatusOptions(
                selected: controller.status,
                onSelected: controller.setStatus,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Spacer(),
                  TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text(
                        'task_cancel'.tr,
                        style: const TextStyle(color: Colors.white),
                      )),
                  TextButton(
                      onPressed: () {
                        Get.back();
                        controller.insertDataInDatabase();
                      },
                      child: Text(
                        'task_create'.tr,
                        style: const TextStyle(color: Colors.white),
                      ))
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
