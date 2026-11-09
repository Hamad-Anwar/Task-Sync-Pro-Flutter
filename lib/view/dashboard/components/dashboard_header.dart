import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common widgets/back_button.dart';

/// Header do dashboard: voltar + título.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: const CustomBackButton(),
        ),
        const SizedBox(width: 16),
        Text(
          'dash_title'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ],
    );
  }
}
