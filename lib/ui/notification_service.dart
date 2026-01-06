import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'parkhive_channel';
  static const String _channelName = 'ParkHive Notifications';
  static const String _channelDesc =
      'Notifikasi seputar parkir, poin, dan verifikasi';

  /// INIT — panggil SEKALI (di main / root page)
  Future<void> init({
    void Function(String? payload)? onNotificationTap,
  }) async {
    if (kIsWeb) return;

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        onNotificationTap?.call(response.payload);
      },
    );

    if (Platform.isAndroid) {
      await _createAndroidChannel();
    }

    if (Platform.isIOS) {
      await _requestIOSPermission();
    }
  }

  /// ANDROID PERMISSION (Android 13+)
  Future<void> _requestAndroidPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
  }

  /// iOS PERMISSION
  Future<void> _requestIOSPermission() async {
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// ANDROID CHANNEL
  Future<void> _createAndroidChannel() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
    );

    await android?.createNotificationChannel(channel);
  }

  /// SHOW NOTIFICATION
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _plugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }
}
