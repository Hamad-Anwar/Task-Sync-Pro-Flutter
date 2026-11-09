import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Os três contadores abaixo do anel: concluídas, em andamento, não iniciadas.
class StatusCounters extends StatelessWidget {
  final int completed;
  final int inProgress;
  final int notStarted;

  const StatusCounters({
    super.key,
    required this.completed,
    required this.inProgress,
    required this.notStarted,
  });

  @override
  Widget build(BuildContext context) {
    // Um Expanded por coluna: somadas, as três labels passam da largura útil de
    // um celular comum (~350px dentro do card) e a Row estourava com o tamanho
    // intrínseco. Dividir em três partes iguais mantém o alinhamento e cabe.
    return Row(
      children: [
        Expanded(
          child: _Counter(
            value: completed,
            label: 'dash_counter_completed'.tr,
            color: Colors.pinkAccent,
          ),
        ),
        Expanded(
          child: _Counter(
            value: inProgress,
            label: 'dash_counter_in_progress'.tr,
            color: Colors.purpleAccent,
          ),
        ),
        Expanded(
          child: _Counter(
            value: notStarted,
            label: 'dash_counter_not_started'.tr,
            color: Colors.white38,
          ),
        ),
      ],
    );
  }
}

class _Counter extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _Counter({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 8,
          width: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          '$value',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white54,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
