import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:to_do_app/view%20model/controller/add_task_controller.dart';
import 'date_time_container.dart';
class DateTimeRow extends StatelessWidget {
  final controller=Get.put(AddTaskController());
  DateTimeRow({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Date',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17),
            ),
            const SizedBox(
              height: 10,
            ),
            Obx(() => DateTimeContainer(text: controller.date.value.isEmpty? 'dd/mm/yyyy' : controller.date.value, icon: const Icon(
              FontAwesomeIcons.calendar,
              color: Colors.white24,
              size: 20,
            ), onTap: () {
              controller.pickDate(context);
            },))
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
                text: const TextSpan(children: [
                  TextSpan(
                    text: 'Time',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
                  TextSpan(
                    text: '   (optional)',
                    style: TextStyle(color: Colors.white30, fontSize: 13),
                  )
                ])),
            const SizedBox(
              height: 10,
            ),

            Obx(() => DateTimeContainer(text:controller.time.value.isEmpty?  'hh/mm' : controller.time.value, icon: const Icon(
              Icons.watch,
              color: Colors.white24,
              size: 20,
            ), onTap: () {
              controller.picTime(context);
            },))
          ],
        )
      ],
    );
  }
}
