import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Channels
  static const String _channelIdCycle = 'cycle_channel';
  static const String _channelIdPills = 'pills_channel';

  // Payloads (единые по приложению)
  static const String payloadCalendar = 'screen_calendar';
  static const String payloadCOC = 'screen_coc';

  Future<void> init({Function(String?)? onNotificationTap}) async {
    await _configureLocalTimeZone();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        debugPrint("🔔 Notification tapped. payload=$payload");
        onNotificationTap?.call(payload);
      },
    );

    await _ensureAndroidChannels();
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    try {
      final String timeZoneName =
      (await FlutterTimezone.getLocalTimezone()).toString();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint("🕒 Local timezone set: $timeZoneName");
    } catch (e) {
      debugPrint("⚠️ Could not set local timezone, fallback to UTC: $e");
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  Future<void> _ensureAndroidChannels() async {
    if (!Platform.isAndroid) return;

    final android =
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    const cycleChannel = AndroidNotificationChannel(
      _channelIdCycle,
      'Cycle Updates',
      description: 'Notifications about period start and fertility window',
      importance: Importance.defaultImportance,
    );

    const pillsChannel = AndroidNotificationChannel(
      _channelIdPills,
      'Pill Reminders',
      description: 'Daily reminders to take contraception',
      importance: Importance.max,
    );

    try {
      await android.createNotificationChannel(cycleChannel);
      await android.createNotificationChannel(pillsChannel);
      debugPrint("✅ Android channels ensured");
    } catch (e) {
      debugPrint("⚠️ Could not create Android channels: $e");
    }
  }

  /// 🔒 Permissions
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? ios =
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

      final bool? result = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }

    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? android =
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final bool? result =
      await android?.requestNotificationsPermission();
      return result ?? false;
    }

    return false;
  }


  /// 📅 One-time schedule (cycle)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      final tz.TZDateTime target = tz.TZDateTime.from(scheduledDate, tz.local);

      if (target.isBefore(now)) return;

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        target,
        _notificationDetails(channelId: _channelIdCycle),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      debugPrint("✅ Scheduled [$id] '$title' at $target payload=$payload");
    } catch (e) {
      debugPrint("❌ Error scheduling notification [$id]: $e");
    }
  }

  /// 💊 Daily schedule (pills)
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // exact -> fallback inexact
      try {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          _notificationDetails(channelId: _channelIdPills),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payloadCOC,
        );
      } catch (e) {
        debugPrint("⚠️ exactAllowWhileIdle failed, fallback to inexact: $e");
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          _notificationDetails(channelId: _channelIdPills),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payloadCOC,
        );
      }

      final hh = time.hour.toString().padLeft(2, '0');
      final mm = time.minute.toString().padLeft(2, '0');
      debugPrint("💊 Daily pill scheduled at $hh:$mm");
    } catch (e) {
      debugPrint("❌ Error scheduling daily pill [$id]: $e");
    }
  }

  NotificationDetails _notificationDetails({required String channelId}) {
    final bool isPill = channelId == _channelIdPills;

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        isPill ? 'Pill Reminders' : 'Cycle Updates',
        channelDescription: isPill
            ? 'Daily reminders to take contraception'
            : 'Notifications about period start and fertility window',
        importance: isPill ? Importance.max : Importance.defaultImportance,
        priority: isPill ? Priority.high : Priority.defaultPriority,
        enableVibration: true,
        playSound: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  Future<void> cancelAll() async => _notificationsPlugin.cancelAll();

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
