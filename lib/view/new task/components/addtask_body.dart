import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_app/view%20model/controller/add_task_controller.dart';
import 'package:to_do_app/view/new%20task/components/title.dart';
import 'package:to_do_app/view/new%20task/components/upper_body.dart';
import '../../sign up/components/button.dart';
import 'add_fild.dart';
import 'datetime_row.dart';
import 'image_container_list.dart';

class TaskBody extends StatelessWidget {
   TaskBody({super.key});
   final controller=Get.put(AddTaskController());
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return Container(
        height: 750,
        padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const UpperBody(),
          ImageContainerList(),
          const SizedBox(
            height: 20,
          ),
          TitlePeriority(),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Category',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(
            height: 10,
          ),
          Obx(
            ()=> AddInputField(
              controller: controller.category.value,
              focus: controller.categoryFocus.value,
              onTap: ()=>controller.setCategoryFocus(),
              onTapOutSide: ()=>controller.onTapOutside(),
              hint: 'Pick a Category',
              width: size.width,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Description',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(
            height: 10,
          ),
          Obx(() => AddInputField(
            controller: controller.description.value,
            focus: controller.descriptionFocus.value,
            onTap: ()=>controller.setDescriptionFocus(),
            onTapOutSide: ()=>controller.onTapOutside(),
            hint: 'Enter description of your task (optional)',
            width: size.width,
          ),),
          const SizedBox(
            height: 20,
          ),
           DateTimeRow(),
          const SizedBox(
            height: 20,
          ),
          Obx(() => AccountButton(
            text: 'Create Task',
            loading: controller.loading.value,
            onTap: () async {
              // controller.insertDataInDatabase();
              controller.showProgressPicker(context);
            },
          ))
        ]),
      ),
    );
  }
}
