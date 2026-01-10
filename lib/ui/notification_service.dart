import 'dart:async';
import '../services/api_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class NotificationService {
  // Singleton pattern agar instance-nya satu saja
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Timer? _timer;
  int _lastNotifId = 0;
  bool _isPolling = false;

  String _titleFromNotif(Map notif) {
    switch (notif['judul']) {
      case 'Laporan Diverifikasi':
        return 'Laporan Diverifikasi';
      case 'laporan Ditolak':
        return 'Laporan Ditolak';
      default:
        return 'Notifikasi';
    }
  }

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // 🔴 TAMBAHKAN INI
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'parkhive_channel_id',
      'ParkHive Notifications',
      description: 'Notifikasi seputar parkir dan poin',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _requestPermission();
  }

  void startPolling() {
    if (_isPolling) return;

    _lastNotifId = 0; // reset agar notif baru bisa muncul
    _isPolling = true;

    Timer.periodic(
      const Duration(seconds: 15),
      (_) {
        debugPrint('🔔 Polling notif...');
        _checkNewNotification();
      },
    );
  }

  /// Panggil saat logout
  void stopPolling() {
    _timer?.cancel();
    _isPolling = false;
  }

  Future<void> _requestPermission() async {
    await Permission.notification.request();
  }

  // Fungsi untuk memunculkan notifikasi
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'parkhive_channel_id', // ID Channel unik
      'ParkHive Notifications', // Nama Channel
      channelDescription: 'Notifikasi seputar parkir dan poin',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> _checkNewNotification() async {
    try {
      final api = ApiService();
      final response = await api.getUnreadNotifications();

      if (response.isEmpty) return;

      for (final notif in response) {
        final int notifId = notif['notif_id'];

        if (notifId <= _lastNotifId) continue;

        _lastNotifId = notifId;

        await showNotification(
          id: notifId,
          title: _titleFromNotif(notif),
          body: notif['pesan'] ?? '',
          payload: 'notif_$notifId',
        );
      }
    } catch (e) {
      debugPrint('Notif polling error: $e');
    }
  }
}
