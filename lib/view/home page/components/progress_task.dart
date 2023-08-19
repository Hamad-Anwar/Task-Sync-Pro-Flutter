import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_app/view%20model/controller/home_controller.dart';
import 'package:to_do_app/view/home%20page/components/progress_container.dart';

class ProgressTask extends StatelessWidget {
  final controller = Get.put(HomeController());

  ProgressTask({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 210,
        width: MediaQuery.sizeOf(context).width,
        child: Obx(
          () => ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.list.length,
            itemBuilder: (context, index) {
              if (controller.list[index].show == 'yes') {
                return GestureDetector(
                  onTap: () {
                    // controller.removeFromList(index);
                  },
                  child: ProgressContainer(index: index)
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ));
  }
}
