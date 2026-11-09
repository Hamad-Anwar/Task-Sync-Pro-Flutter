import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_app/model/task_filter.dart';
import 'package:to_do_app/view%20model/controller/home_controller.dart';

import '../../../res/app_color.dart';
import '../../../res/translations/common_tr.dart';

/// Filtros da home: dois dropdowns lado a lado (prioridade e status).
/// Com filtro ativo (diferente de 'All') a borda ganha o gradiente pink/purple.
class FilterDropdowns extends StatelessWidget {
  FilterDropdowns({super.key});
  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _FilterDropdown(
              label: 'home_priority'.tr,
              options: TaskFilter.priorities,
              selected: controller.priorityFilter,
              onSelected: controller.setPriorityFilter,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _FilterDropdown(
              label: 'home_status'.tr,
              options: TaskFilter.statuses,
              selected: controller.statusFilter,
              onSelected: controller.setStatusFilter,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final List<String> options;
  final RxString selected;
  final void Function(String) onSelected;

  const _FilterDropdown({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive = selected.value != 'All';
      return Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: isActive
              ? const LinearGradient(colors: [
                  Colors.pinkAccent,
                  Colors.purpleAccent,
                ])
              : null,
          border: isActive ? null : Border.all(color: Colors.white24),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(13),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selected.value,
              isExpanded: true,
              dropdownColor: primaryColor,
              borderRadius: BorderRadius.circular(14),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isActive ? Colors.pinkAccent : Colors.grey,
              ),
              selectedItemBuilder: (context) => [
                for (final option in options)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '$label: ${trValue(option)}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
              items: [
                for (final option in options)
                  DropdownMenuItem(
                    value: option,
                    child: Text(
                      trValue(option),
                      style: TextStyle(
                        color: selected.value == option
                            ? Colors.pinkAccent
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value != null) onSelected(value);
              },
            ),
          ),
        ),
      );
    });
  }
}
