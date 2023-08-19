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
            const Text(
              'Title',
              style: TextStyle(
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
                hint: 'Enter task title',
                width: size.width / 2.2,
              ),
            )
          ],
        ),
        const SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Periority',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => PeriorityContainer(
                      onTap: ()=> controller.setPeriority(true), focus: controller.lowPeriority.value, type: "Low"),
                ),
                const SizedBox(
                  width: 10,
                ),
                Obx(()=> PeriorityContainer(onTap: ()=>controller.setPeriority(false), focus: !controller.lowPeriority.value, type: "High")),
              ],
            ),
          ],
        )
      ],
    );
  }
}
