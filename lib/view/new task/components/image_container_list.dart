import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_app/view%20model/controller/add_task_controller.dart';
import '../../../res/assets/app_images.dart';
import 'image_container.dart';

class ImageContainerList extends StatelessWidget {
  ImageContainerList({super.key});
  final controller=Get.put(AddTaskController());
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(() => ImageContainer(
          onTap: ()=>controller.setImage(1),
          image: AppImage.back2, focus: controller.selectedImageIndex.value==1,
        ),),
        Obx(() => ImageContainer(
          focus: controller.selectedImageIndex.value==2,
          onTap: ()=>controller.setImage(2),
          image: AppImage.back3,
        ),),
        Obx(() => ImageContainer(
          focus: controller.selectedImageIndex.value==3,
          onTap: ()=>controller.setImage(3),
          image: AppImage.back1,
        ),),
      ],
    );
  }
}
