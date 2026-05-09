import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'inquiry_followup';
  static const String _channelName = 'Follow-Up Reminders';
  static const int _notificationId = 42;

  /// Initializes local notifications and timezone data.
  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );
  }

  /// Schedules (or reschedules) a daily 6 PM IST follow-up reminder.
  /// Cancels it when count is zero.
  Future<void> scheduleFollowUpReminder(int followUpCount) async {
    if (followUpCount <= 0) {
      await _plugin.cancel(_notificationId);
      return;
    }

    final tz.Location india = tz.getLocation('Asia/Kolkata');
    final tz.TZDateTime now = tz.TZDateTime.now(india);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      india,
      now.year,
      now.month,
      now.day,
      18,
      0,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Daily follow-up reminders for your inquiries',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
      ),
    );

    await _plugin.zonedSchedule(
      _notificationId,
      'Follow-up karna mat bhoolo! 🔁',
      'Aapke $followUpCount customers follow-up ka wait kar rahe hain.',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
