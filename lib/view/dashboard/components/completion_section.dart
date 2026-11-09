import 'package:flutter/material.dart';

import '../../../model/task_stats.dart';
import 'completion_ring.dart';
import 'dashboard_card.dart';
import 'status_counters.dart';

/// Seção do topo: anel de conclusão + contadores por estado.
class CompletionSection extends StatelessWidget {
  final TaskStats stats;

  const CompletionSection({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        children: [
          CompletionRing(percent: stats.completionPercent),
          const SizedBox(height: 28),
          StatusCounters(
            completed: stats.completed,
            inProgress: stats.inProgress,
            notStarted: stats.notStarted,
          ),
        ],
      ),
    );
  }
}
