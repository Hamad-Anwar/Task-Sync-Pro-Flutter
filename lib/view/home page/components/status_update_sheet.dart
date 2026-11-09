import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_app/model/task_status.dart';
import 'package:to_do_app/view/common%20widgets/status_options.dart';

import '../../../res/app_color.dart';

/// Bottom sheet de alteração de status de uma task já criada.
class StatusUpdateSheet extends StatelessWidget {
  final ValueChanged<TaskStatus> onSave;

  StatusUpdateSheet(
      {super.key, required TaskStatus initialStatus, required this.onSave})
      : status = initialStatus.obs;

  final Rx<TaskStatus> status;

  static void show(
      {required TaskStatus initialStatus,
      required ValueChanged<TaskStatus> onSave}) {
    Get.bottomSheet(
      StatusUpdateSheet(initialStatus: initialStatus, onSave: onSave),
      backgroundColor: black,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      decoration: const BoxDecoration(
          color: black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 4,
              width: 45,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            'task_update_status'.tr,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(
            height: 20,
          ),
          StatusOptions(
            selected: status,
            onSelected: (value) => status.value = value,
          ),
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () {
              Get.back();
              onSave(status.value);
            },
            child: Container(
              height: 55,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                      colors: [Colors.pinkAccent, Colors.purpleAccent])),
              child: Text(
                'task_save'.tr,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}
