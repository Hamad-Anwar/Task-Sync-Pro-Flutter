import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../res/app_color.dart';
import '../../../utils/utils.dart';
import '../../../view model/controller/home_controller.dart';
import '../../common widgets/back_button.dart';

class ProgressContainer extends StatelessWidget {
  final int index;
  ProgressContainer({super.key, required this.index});
  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 160,
      margin: const EdgeInsets.only(left: 20),
      child: Stack(
        children: [
          Positioned.fill(
              child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(controller.list[index].image),
                      fit: BoxFit.cover)),
            ),
          )),
          Positioned(
              height: 150,
              width: 150,
              top: 1,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaY: 1, sigmaX: 1),
                    child: const SizedBox(),
                  ))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              children: [
                // SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.list[index].date,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                    // Icon(Icons.more_vert_rounded,color: Colors.white,size: 20,)
                    SizedBox(
                      height: 15,
                      width: 20,
                      child: PopupMenuButton(
                        padding: EdgeInsets.zero,
                        color: primaryColor,
                        position: PopupMenuPosition.under,
                        onSelected: (value) {
                          controller.popupMenuSelected(value, index, context);
                        },
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        itemBuilder: (context) {
                          return [
                            const PopupMenuItem(
                                value: 1,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      color: Colors.pinkAccent,
                                    ),
                                    Text(
                                      " Edit",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                )),
                            const PopupMenuItem(
                                value: 2,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      color: Colors.pinkAccent,
                                    ),
                                    Text(
                                      " Delete",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ))
                          ];
                        },
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  controller.list[index].title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  controller.list[index].category,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progress',
                      style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                    Text(
                      '60%',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child:  LinearProgressIndicator(
                    value: 0.6,
                    // double.parse(controller.list[index].progress)/100.0
                    backgroundColor: Colors.deepPurple,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CustomBackButton(
                      height: 30,
                      width: 30,
                      radius: 30,
                      widget: Center(
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: FlutterLogo(),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: 30,
                      width: 100,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        '${Utils.getDaysDiffirece(controller.list[index].date)} Days Left',
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
