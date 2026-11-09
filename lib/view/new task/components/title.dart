import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_app/view%20model/controller/add_task_controller.dart';
import 'package:to_do_app/view/new%20task/components/periority_container.dart';
import 'add_fild.dart';
class TitlePeriority extends StatelessWidget {
  final controller = Get.put(AddTaskController());
  TitlePeriority({super.key});
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'task_title'.tr,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17),
            ),
            const SizedBox(
              height: 10,
            ),
            Obx(
              () => AddInputField(
                controller: controller.title.value,
                focus: controller.titleFocus.value,
                onTap: ()=>controller.setTitleFocus(),
                onTapOutSide: ()=> controller.onTapOutside(),
                hint: 'task_title_hint'.tr,
                width: size.width / 2.6,
              ),
            )
          ],
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'task_priority'.tr,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (final level in const ['Low', 'Medium', 'High']) ...[
                    if (level != 'Low')
                      const SizedBox(
                        width: 6,
                      ),
                    Expanded(
                      child: Obx(
                        () => PeriorityContainer(
                            onTap: () => controller.setPeriority(level),
                            focus: controller.periority.value == level,
                            type: level,
                            width: null,
                            fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
