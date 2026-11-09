import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dashboard_card.dart';
import 'section_title.dart';

/// Card de tasks atrasadas. Em zero mostra um estado positivo, não um zero seco.
class OverdueCard extends StatelessWidget {
  final int overdue;

  const OverdueCard({super.key, required this.overdue});

  @override
  Widget build(BuildContext context) {
    final clear = overdue == 0;
    final accent = clear ? Colors.greenAccent : Colors.pinkAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle('dash_overdue_title'.tr),
        const SizedBox(height: 12),
        DashboardCard(
          child: Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(.15),
                ),
                child: Icon(
                  clear ? Icons.check_rounded : Icons.warning_amber_rounded,
                  color: accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clear
                          ? 'dash_overdue_none'.tr
                          : (overdue == 1
                                  ? 'dash_overdue_one'
                                  : 'dash_overdue_many')
                              .trParams({'count': '$overdue'}),
                      style: TextStyle(
                        color: clear ? Colors.white : accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      clear
                          ? 'dash_overdue_all_clear'.tr
                          : 'dash_overdue_desc'.tr,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
