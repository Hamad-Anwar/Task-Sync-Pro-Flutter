import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_app/model/task_status.dart';

/// Lista das três opções de status. Compartilhada pelo diálogo de criação de
/// task e pelo bottom sheet de alteração, para os dois não divergirem.
class StatusOptions extends StatelessWidget {
  final Rx<TaskStatus> selected;
  final ValueChanged<TaskStatus> onSelected;

  const StatusOptions({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final status in TaskStatus.values)
              _StatusTile(
                status: status,
                isSelected: selected.value == status,
                onTap: () => onSelected(status),
              ),
          ],
        ));
  }
}

class _StatusTile extends StatelessWidget {
  final TaskStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusTile({
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected ? Colors.white10 : Colors.transparent,
          border: Border.all(
            color: isSelected ? status.color : Colors.white24,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 10,
              width: 10,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: status.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                status.labelKey.tr,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, color: status.color, size: 20),
          ],
        ),
      ),
    );
  }
}
