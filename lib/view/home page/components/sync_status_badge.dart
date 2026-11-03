import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Estado da sincronização para o usuário. Fica oculto quando está tudo
/// enviado; aparece com alterações pendentes ou quando o envio falhou
/// (toque para tentar de novo). Puro: quem usa liga isso ao controller.
class SyncStatusBadge extends StatelessWidget {
  final int pending;
  final bool failed;
  final VoidCallback? onRetry;

  const SyncStatusBadge({
    super.key,
    required this.pending,
    required this.failed,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (!failed && pending <= 0) return const SizedBox.shrink();
    final color = failed ? Colors.redAccent : Colors.amberAccent;
    final text = failed
        ? 'sync_failed'.tr
        : 'sync_pending'.trParams({'count': '$pending'});
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 30, right: 30),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: onRetry,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(failed ? Icons.cloud_off : Icons.sync,
                    size: 16, color: color),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    text,
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
