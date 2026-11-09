import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/task_stats.dart';
import '../../res/app_color.dart';
import '../../view model/controller/home_controller.dart';
import 'components/completion_section.dart';
import 'components/dashboard_header.dart';
import 'components/empty_dashboard.dart';
import 'components/group_stat_section.dart';
import 'components/overdue_card.dart';

/// Visão agregada das tasks. Não busca nada: deriva tudo da lista que o
/// HomeController já mantém, então acompanha as mudanças de progresso sozinha.
class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  /// Reaproveita o controller que a home já registrou — instanciar outro
  /// duplicaria os listeners do Firebase e o estado da lista.
  final controller = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: DashboardHeader(),
            ),
            Expanded(
              child: Obx(() {
                final stats = TaskStats.from(controller.list);
                if (stats.isEmpty) {
                  return const SingleChildScrollView(
                    child: EmptyDashboard(),
                  );
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CompletionSection(stats: stats),
                      const SizedBox(height: 30),
                      GroupStatSection(
                        title: 'dash_by_category'.tr,
                        stats: stats.byCategory,
                        emptyMessage: 'dash_no_categories'.tr,
                      ),
                      const SizedBox(height: 30),
                      OverdueCard(overdue: stats.overdue),
                      const SizedBox(height: 30),
                      GroupStatSection(
                        title: 'dash_by_priority'.tr,
                        stats: stats.byPriority,
                        emptyMessage: 'dash_no_priorities'.tr,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
