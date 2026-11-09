import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:to_do_app/model/task_model.dart';

/// Agenda/cancela lembretes locais das tasks.
/// Data/hora chegam como strings nos formatos usados pelos pickers do app:
/// date = 'd MMM y' (ex: '1 Sep 2026'), time = 'hh:mm a' (ex: '05:30 PM').
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      tz.initializeTimeZones();
      try {
        final String localTimeZone = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(localTimeZone));
      } catch (_) {
        // Mantém tz.local default (UTC) se não conseguir resolver o fuso.
      }

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      await _plugin.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
      );

      // Android 13+ pede permissão em runtime.
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService.init falhou: $e');
    }
  }

  static Future<void> scheduleTaskReminder(TaskModel task) async {
    if (!_initialized) return;
    final DateTime? when = _parseTaskDateTime(task.date, task.time);
    if (when == null) return;
    if (!when.isAfter(DateTime.now())) return; // horário já passou

    try {
      final tz.TZDateTime scheduled = tz.TZDateTime.from(when, tz.local);
      await _plugin.zonedSchedule(
        _notificationId(task.key),
        task.title?.isNotEmpty == true ? task.title : 'Task reminder',
        task.description?.isNotEmpty == true
            ? task.description
            : 'You have a task scheduled for now.',
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminders',
            'Task Reminders',
            channelDescription: 'Reminders for scheduled tasks',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: task.key,
      );
    } catch (e) {
      debugPrint('NotificationService.scheduleTaskReminder falhou: $e');
    }
  }

  static Future<void> cancelTaskReminder(String? key) async {
    if (key == null || key.isEmpty) return;
    try {
      await _plugin.cancel(_notificationId(key));
    } catch (e) {
      debugPrint('NotificationService.cancelTaskReminder falhou: $e');
    }
  }

  /// Id de 31 bits estável derivado da key da task (key é
  /// microsecondsSinceEpoch em string; fallback FNV-1a para outros formatos —
  /// String.hashCode do Dart não é garantidamente estável entre execuções).
  static int _notificationId(String? key) {
    final String value = key ?? '';
    final int? numeric = int.tryParse(value);
    if (numeric != null) return numeric & 0x7fffffff;
    int hash = 0x811c9dc5;
    for (final int unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }

  static DateTime? _parseTaskDateTime(String? date, String? time) {
    if (date == null || date.trim().isEmpty) return null;
    try {
      // Formatos de ARMAZENAMENTO — fixos em en_US, independem do locale do app.
      final DateTime day =
          DateFormat('d MMM y', 'en_US').parseStrict(date.trim());
      if (time == null || time.trim().isEmpty) {
        // Sem hora: lembra às 9h do dia da task.
        return DateTime(day.year, day.month, day.day, 9);
      }
      final DateTime clock =
          DateFormat('hh:mm a', 'en_US').parseStrict(time.trim());
      return DateTime(day.year, day.month, day.day, clock.hour, clock.minute);
    } catch (_) {
      return null;
    }
  }
}
