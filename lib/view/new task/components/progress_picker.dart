import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_app/view%20model/controller/add_task_controller.dart';

import '../../../res/app_color.dart';

class ProgressPicker {
  ProgressPicker(BuildContext context) {
    final controller = Get.put(AddTaskController());
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: primaryColor,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Text(
                'Set Progress',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Progress',
                    style: TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Obx(
                    () => Text(
                      '${controller.progress.value.toInt()}%',
                      style: const TextStyle(
                          color: Colors.white70, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
            Obx(() => Slider(
                  min: 0.0,
                  max: 100.0,
                  activeColor: Colors.pinkAccent,
                  value: controller.progress.value,
                  onChanged: (value) {
                    controller.progress.value = value;
                  },
                )),
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
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white),
                      )),
                  TextButton(
                      onPressed: () {
                        Get.back();
                        controller.insertDataInDatabase();
                      },
                      child: const Text(
                        "Create",
                        style: TextStyle(color: Colors.white),
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
