import 'package:flutter/material.dart';

import '../../../model/task_stats.dart';
import 'dashboard_card.dart';
import 'group_stat_row.dart';
import 'section_title.dart';

/// Seção com uma linha por grupo (usada por categoria e por prioridade).
class GroupStatSection extends StatelessWidget {
  final String title;
  final List<GroupStat> stats;
  final String emptyMessage;

  const GroupStatSection({
    super.key,
    required this.title,
    required this.stats,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title),
        const SizedBox(height: 12),
        DashboardCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: stats.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    emptyMessage,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (final stat in stats) GroupStatRow(stat: stat),
                  ],
                ),
        ),
      ],
    );
  }
}
