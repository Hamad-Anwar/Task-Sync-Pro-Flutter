import 'package:flutter/material.dart';

import '../../../model/task_stats.dart';
import '../../../res/translations/common_tr.dart';
import 'dashboard_theme.dart';

/// Valores internos de prioridade — só esses passam pelo trValue; categorias
/// são dado do usuário e ficam como estão.
const Set<String> _priorityValues = {'Low', 'Medium', 'High'};

/// Uma linha de grupo (categoria ou prioridade): nome, barra e 'X/Y (Z%)'.
class GroupStatRow extends StatelessWidget {
  final GroupStat stat;

  const GroupStatRow({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    // GroupStat.percent já devolve 0 para grupo vazio — nada de divisão aqui.
    final fraction = (stat.percent / 100).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _priorityValues.contains(stat.label)
                      ? trValue(stat.label)
                      : stat.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${stat.completed}/${stat.total} (${formatPercent(stat.percent)})',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _GradientBar(fraction: fraction),
        ],
      ),
    );
  }
}

class _GradientBar extends StatelessWidget {
  /// 0..1 — já validado por quem constrói.
  final double fraction;

  const _GradientBar({required this.fraction});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fullWidth = constraints.maxWidth;
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Container(
                height: 8,
                width: fullWidth,
                color: Colors.white.withOpacity(.08),
              ),
              Container(
                height: 8,
                width: fullWidth * fraction,
                decoration: const BoxDecoration(gradient: dashboardGradient),
              ),
            ],
          ),
        );
      },
    );
  }
}
